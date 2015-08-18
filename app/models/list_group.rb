#NOTE:  The purpose of this model is to group lists with the same name together
#in the feed, avoiding ever showing a list with the same name twice, and to
#update items to display things chronologically.
class ListGroup
  include Mongoid::Document
  include Mongoid::Timestamps

  #XXX: This type of relation will store the array on the document itself.  By
  #using this type of relation we can sort by updated_at on the ListGroup record
  #Also, in this way we can just fetch lists groups and then fetch dependency
  #lists.  If the relation was on the list, we'd have to refilter out lists with
  #the same name
  has_and_belongs_to_many :users, :inverse_of => nil #this allows us to query all list groups containing certain user ids, e.g. for my feed
  #NOTE: This will have some duplicate user_ids so we can delete a user_id when
  #a list is deleted without having to check if there's another list by that
  #user
  has_and_belongs_to_many :lists, :inverse_of => nil, :order => :created_at.desc #last created or updated list goes last
  delegate :intralist, :to => :first_list
  delegate :intralist_id, :to => :first_list
  field :name, :type => String
  field :tags, :type => Hash, :default => {}

  index({ :updated_at => 1 }, { :background => true })

  def first_list
    lists.first
  end

  def self.create_or_update_list_group(list)
    #XXX: Some ListGroups do not have "_type" set to "ListGroup" upon creation. (mongoid seems
    #to do this through lazy changes somehow).
    list_group = ListGroup.where(:name => list.name, :_type.ne => "RequestListGroup").first

    if list_group #update case
      list_group.list_ids << list.id
      list_group.user_ids << list.user_id
      list_group.add_tags(list.tags.map(&:name))
      list_group.save
    elsif !list.is_a? Response #create case
      #Responses don't create new feed items, they're only added to existing ones
      list_group = ListGroup.new(:list_ids => [list.id],
                               :user_ids => [list.user_id],
                               :name => list.name)

      existing_response_ids = Response.where(:name => list_group.name,
                                             :id.ne => list.id).only(:id).map(&:id)
      list_group.list_ids.unshift(existing_response_ids)
      list_group.list_ids.flatten!
      list_group.add_tags(list.tags.map(&:name))
      list_group.save!
    end
  end

  def self.my_feed(user, page)
    following_ids = user.following.map(&:user_id)
    ListGroup.where(:user_ids.in => following_ids).desc(:updated_at).page(page)
  end

  def trending
    List.trending.page(params[:page]).map(&:list_group)
  end

  def self.remove_from_list_group(list)
    list_group = ListGroup.where(:_type.ne => "RequestListGroup", :list_ids.in => [list.id]).first
    list_group.list_ids.delete(list.id)
    list_group.user_ids.delete(list.user_id)
    if list_group.list_ids.length > 0
      list_group.remove_tags(list.tags.map(&:name))
      list_group.save
    else
      list_group.destroy
    end

    if list.is_a? Response
      request_list_group = RequestListGroup.where(:list_ids.in => [list.id]).first
      request_list_group.list_ids.delete(list.id)
      request_list_group.user_ids.delete(list.user_id)
      request_list_group.remove_tags(list.tags.map(&:name))
      request_list_group.save
    end
  end

  def add_tags(_tags)
    _tags.each do |tag|
      if self.tags[tag]
        self.tags[tag] += 1
      else
        self.tags[tag] = 1
      end
    end
  end

  def remove_tags(_tags)
    _tags.each do |tag|
      self.tags[tag] -= 1
      self.tags.delete(tag) if (self.tags[tag] == 0)
    end
  end

  def update_tags(old_tags, new_tags)
    remove_tags(old_tags)
    add_tags(new_tags)
    save!
  end

end
