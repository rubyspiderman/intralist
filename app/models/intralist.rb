class Intralist
  include Mixins::ListCommon

  include Elasticsearch::Model

  include Searchable::Intralist
  include Mixins::Indexer::AsyncIndexer

  field :downcased_name
  #TODO: Finish implementing this for CRUD.  To keep things simple for now, we
  #can just map through all of the contributors to the Intralist items if we
  #need to list contributors, although we don't have a need with current
  #designs.  To implement this fully for all CRUD cases would require a lot more
  #logic.
  # field :contributors, type: Array, :default => []

  #NOTE: An intralist should always have at least 2 lists.  This is the true valid
  #state of the data and it makes updating/deleting lists easier to manage the
  #associated intralist in a consistent fashion.
  #
  #We can't really add a validation for this as it would have to query the DB
  #for every save, unless an array of lists was maintained on the intralist
  #itself.
  #
  #The presentation logic will take care of only showing an intralist if it
  #contains at least one item.
  has_many :lists

  embeds_many :intralist_items
  belongs_to :user

  scope :recent, order_by(:created_at => :desc)

  settings :index => { :number_of_shards => 1  } do
    mapping :dynamic => 'false' do
      indexes :private, :type => 'boolean'
      indexes :name, :type => 'string'
      indexes :slug, :type => 'string'
      indexes :bookmarks_count , :type => 'integer'
      indexes :up_count, :type => 'integer'
      indexes :intralist_items do
        indexes :name, :type => 'string'
      end
      indexes :permalink, :type => 'string'
      indexes :sub_text, :type => 'string'
    end
  end

  #We need to force a full update of the document, rather than just updating
  #dirty changes like the elasticsearch model gem does.  Otherwise the sub_text
  #field is never updated, since it's a virtual attribute.
  def reindex
    __elasticsearch__.index_document({})
  end

  def self.find_by_name(list)
    where(:name => list).first
  end

  def self.create_or_update_intralist(list)
    intralist = Intralist.find_or_initialize_by(:downcased_name => list.name.to_s.downcase) 
    if intralist.new_record?
      try_create_intralist(intralist, list)
    else
      intralist.add_list(list)
    end
    intralist
  end

  def remove_list(list)
    downcased_item_names = list.items.map { |item| item.name.to_s.downcase }

    intralist_items = self.intralist_items.select { |item| downcased_item_names.include? item.name.to_s.downcase }
    intralist_items.each do |item|
      if item.count > 1
        item.count -= 1
        item.contributors.delete(list.user_id)
     else
       item.delete
     end
    end

    save_or_destroy!
  end

  def as_indexed_json(options = {})
    as_json(:include => [:intralist_items],
            :methods => [:permalink, :sub_text, :title_text, :icon_url]
           )
  end

  def title_text
    begin
      self.name
    rescue
      ""
    end
  end

  def icon_url
    return '' if self.lists.empty? || self.lists.first.items.empty?
    self.lists.first.items.first.image_url.to_s
  end

  def permalink
    list = self.lists.first
    "/lists/#{list.slug}"
  rescue => e
    '/'
  end

  # Text thats displayed when a user is searched for using typeahead
  def sub_text
    begin
      "Intralist - powered by #{self.lists.count} lists"
    rescue => e
      "Intralist - powered by 2 lists."
    end
  end

  def add_list(list)
    list_item_names = list.items.map { |i| i.name }

    self.intralist_items.select { |item| list_item_names.map(&:downcase).include? item.name.to_s.downcase }.each do |item|
      item.count += 1
      item.contributors << list.user_id unless item.contributors.include? list.user_id

      item_name = list_item_names.detect { |name| name.to_s.downcase == item.name.to_s.downcase }
      list_item_names.delete(item_name)
    end

    list_item_names.each do |name|
      self.intralist_items.create(:name => name,
                                  :contributors => [list.user_id])
    end

    self.save!

    unless list.intralist_id
      list.intralist_id = self.id
      list.save
    end
  end

  private
  #unless there is an intralist item with a count of 2, destroy the bitch
  def save_or_destroy!
    if self.intralist_items.map(&:count).none? { |count| count > 1 }
      lists = List.where(:intralist_id => self.id)
      lists.each do |l|
        l.update_attribute(:intralist_id, nil)
      end
      self.destroy
    else
      self.save
    end
  end

  #TODO: Make this race proof
  def self.try_create_intralist(intralist, list)
    list_items = []
    lists = List.where("name" => /^#{Regexp.escape list.name}$/i).asc(:created_at)

    if lists.count >= 2
      lists.each do |list|
        list.items.each {|item| list_items << {:name => item.name, :count => 1, :contributor => list.user.id}}
      end

      list_items = list_items.group_by { |list_hash| list_hash[:name].to_s.downcase }.map { |name, items|
        {:name => items[0][:name],
         :count => items.map { |item| item[:count] }.sum,
         :contributors => items.map { |item| item[:contributor] }
        }
      }
      if list_items.any? { |item_name, v| item_name[:count] > 1 }
        # that means we have list item overlap and an intralist should be created.
        intralist.name = lists[0].name
        intralist.save
        list_items.each do |item|
          item[:contributors].uniq!
          intralist.intralist_items.create item
        end

        list.intralist_id = intralist.id #XXX: this is so the intralist_id gets set without having to reload the list during the callback cycle
        list.save

        lists.each do |_list|
          _list.update_attribute(:intralist_id, intralist.id) unless list.id == _list.id
        end
      end
    end
  end

end
