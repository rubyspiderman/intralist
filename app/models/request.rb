#TODO:  Migrate all old Requests
class Request
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mixins::ListCommon
  include Mixins::Sluggable

  include Elasticsearch::Model
  include Elasticsearch::Model::Callbacks
  has_many :responses
  belongs_to :user

  default_scope order_by(:created_at => :desc)
  after_create :notify_followers
  after_create :create_list_group
  after_update :update_list_group, :if => :name_changed?
  after_destroy :remove_list_group
  field :private, :type => Boolean, :default => false

  settings :index => { :number_of_shards => 1  } do
    mapping :dynamic => 'false' do
      indexes :name, :type => 'string'
      indexes :slug, :type => 'string'
      #anything else? test search
    end
  end

  #TOOD: Make this a proper mongoid relation?
  def list_group
    RequestListGroup.where(:request_id => id).last
  end

  def as_indexed_json(options = {})
    #FIXME
    as_json(:include => [],
            :methods => []
            )
  end

  private
  def notify_followers
    user.followers.each do |f|
     Notification.new_request(user, self, f.parent)
    end
  end

  def create_list_group
    RequestListGroup.create_list_group(self)
  end

  def remove_list_group
    RequestListGroup.where(:request_id => self.id).destroy
  end

  def update_list_group
    group = RequestListGroup.where(:request_id => self.id).first
    group.update_attributes(:name => self.name)
  end
end
