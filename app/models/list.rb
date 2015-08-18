class List
  include Mixins::ListCommon
  include Mixins::Sluggable
  include Elasticsearch::Model

  include Searchable::List

  field :private, :type => Boolean, :default => false
  field :parent_list_id, :type => Moped::BSON::ObjectId
  field :parent_list_creator
  field :cid
  field :promoted, :type => Boolean, :default => false
  field :carousel, :type => Boolean, :default => false
  # TODO: promoted should be protected attribute

  embeds_many :items
  embeds_many :tags
  belongs_to :user, :inverse_of => [:lists, :requests]
  belongs_to :intralist
  has_many :copies, :class_name => "List", :foreign_key => "parent_list_id"
  belongs_to :parent_list, :class_name => "List", :inverse_of => :copies, counter_cache: true

  validates_presence_of :name

  # default_scope where(:private => false)
  scope :most_popular, order_by(:up_count => :desc)
  scope :trending, order_by(:vote_count => "desc")
  scope :most_copied, order_by(:copies_count => "desc")
  scope :recent, order_by(:created_at => :desc)
  scope :month_old, where(:created_at.gte => (30.days.ago))
  scope :limit_5, limit(5)
  scope :filter_requests, where(:request_id => nil)

  after_destroy -> { intralist.remove_list(self) if self.intralist }

  before_create :generate_parent_list_creator, :if => lambda { |list| list.parent_list_id.present? }
  before_create :generate_content_source_name, :if => lambda { |list| list.content_source_url.present? }
  before_update :generate_content_source_name, :if => lambda { |list| list.content_source_url_changed? }
  after_save :reindex_intralist, :if => lambda { |list| list.intralist_id.present? }

  after_create -> { Intralist.create_or_update_intralist(self) }
  after_create :create_or_update_list_group
  after_update :update_list_groups, if: -> { name_changed? && name_was }
  after_destroy :remove_from_list_group

  index({ :promoted => 1 }, { :background => true })

  include Mixins::Indexer::AsyncIndexer

  #ElasticSearch Mappings

  settings :index => { :number_of_shards => 1  } do
    mapping :dynamic => 'false' do
      indexes :private, :type => 'boolean'
      indexes :name, :type => 'string'
      indexes :slug, :type => 'string'
      indexes :bookmarks_count , :type => 'integer'
      indexes :item_names, :type => 'string'
      indexes :up_count, :type => 'integer'
      indexes :permalink, :type => 'string'
      indexes :sub_text, :type => 'string'
      indexes :title_text, :type => 'string'
      indexes :creator_name, :type => 'string'
      indexes :creator_avatar, :type => 'string'
      indexes :cover_image, :type => 'string'
    end
  end

  #TOOD: Make this a proper mongoid relation?
  def list_group
    ListGroup.where(:list_ids.in => [id]).last
  end

  def item_names
    self.items.map(&:name).join(' ')
  end

  def self.group_by_name
    map = %Q{
      function () {
        emit(this.name, {count: 1});
      }
    }
    reduce = %Q{
      function(key, values) {
        var result = {count: 0};
        values.forEach(function(value) {
          result.count += value.count;
        });
        return result;
      }
    }
    self.all.
      map_reduce(map, reduce).out(inline: true)
  end

  def self.related_by_tags_to(list)
    self.in("tags.name" => list.tags.map {|t| t.name}).nin(:id => list.id)
  end

  def images
    items.where(:picture.ne => nil)
  end

  def update_list(params)
    self.name = params[:name] if params[:name]
    self.promoted = params[:promoted]
    self.carousel = params[:carousel]
    self.content_source_url = params[:content_source_url]
    self.description = params[:description]

    old_list = self.dup
    old_list.name = self.name_was

    self.items = params[:items]

    #re-register the list with intralist
    if self.intralist
      intralist.remove_list(old_list) #remove all original items and attempt to destroy intralist
      self.intralist_id = nil
    end

    self.save
    Intralist.create_or_update_intralist(self) #this will save the list
  end

  def as_indexed_json(options = {})
    as_json(:include => [:items, :tags],
            :methods => [:permalink, :sub_text, :title_text, :icon_url, :item_names, :creator_name, :creator_avatar, :cover_image]
            )
  end

  def title_text
    begin
      self.name.to_s
    rescue => e
      ""
    end
  end

  def creator_name
      begin
        self.user.username
      rescue => e
        ""
      end
  end

  def creator_avatar
    begin
      self.user.profile.avatar
    rescue => e
      ""
    end
  end

  def cover_image
    begin
      self.items[0].image_url
    rescue => e
      ""
    end
  end

  def icon_url
    return '' if self.items.empty?
    self.items.first.image_url.to_s
  end

  # Text thats displayed when a user is searched for using typeahead
  def sub_text
    begin
      "List - created by: #{self.user.username}"
    rescue => e
      "List - created by: user_#{self.user.id}"
    end
  end

  def reindex_intralist
    self.intralist.reindex
  end

  private

  def generate_parent_list_creator
    list = List.find(parent_list_id)
    self.parent_list_creator = list.user.username
    List.instantiate
  end

  def generate_content_source_name
    source_url = self.content_source_url
    source_url = 'http://' + source_url unless source_url.match(/^http:\/\//)
    source_name = Addressable::URI.parse(source_url).host.gsub('www.', '')
    self.content_source_name = source_name
  end

  def update_list_groups
    ListGroup.remove_from_list_group(self)
    ListGroup.create_or_update_list_group(self)
  end

  def create_or_update_list_group
    ListGroup.create_or_update_list_group(self)
  end

  def remove_from_list_group
    ListGroup.remove_from_list_group(self)
  end
end
