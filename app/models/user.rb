class User
  include Mongoid::Document
  include Mongoid::Timestamps
  include Elasticsearch::Model
  include Searchable::User

  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
    :recoverable, :rememberable, :trackable, :validatable, :omniauthable

  ## Database authenticatable
  field :username
  field :downcased_username
  field :utility_token

  field :email, :default => ""
  field :encrypted_password

  validates_presence_of :username
  # validates_presence_of :password
  # validates_presence_of :encrypted_password

  ## Recoverable
  field :reset_password_token
  field :reset_password_sent_at, :type => Time

  ## Rememberable
  field :remember_created_at, :type => Time

  ## Trackable
  field :sign_in_count,      :type => Integer, :default => 0
  field :current_sign_in_at, :type => Time
  field :last_sign_in_at,    :type => Time
  field :current_sign_in_ip
  field :last_sign_in_ip
  field :admin,               :type => Boolean, :default => false
  field :last_viewed_notifications, :type => Time
  field :send_notification_email, :type => Boolean, :default => true

  ## Confirmable
  # field :confirmation_token,   :type => String
  # field :confirmed_at,         :type => Time
  # field :confirmation_sent_at, :type => Time
  # field :unconfirmed_email,    :type => String # Only if using reconfirmable

  ## Lockable
  # field :failed_attempts, :type => Integer, :default => 0 # Only if lock strategy is :failed_attempts
  # field :unlock_token,    :type => String # Only if unlock strategy is :email or :both
  # field :locked_at,       :type => Time

  ## Token authenticatable
  # field :authentication_token, :type => String

  # Non devise fields
  # TODO: These live in the profile to, as they should.  Move Birthday to profile and get rid of these.
  field :first_name
  field :last_name
  field :gender
  field :birthday, :type => Date
  field :last_notification_id

  has_many :lists, :dependent => :destroy
  # embeds_many :authorizations
  has_many :authorizations, :dependent => :destroy
  embeds_many :followers
  embeds_many :following
  embeds_many :bookmarks
  embeds_many :notifications
  has_many :requests, :class_name => "List", :foreign_key => "request_id", :dependent => :destroy
  embeds_one :profile
  accepts_nested_attributes_for :profile

  attr_accessor :login

  validates_uniqueness_of :username
  validates_format_of      :username, :with => /\A\_?[[:alnum:]][[:alnum:]\_]+\z/, :message => "username can only contain letters, numbers, and underscores"

  attr_accessible :login, :username, :email, :password, :password_confirmation, :profile_attributes, :send_notification_email, :last_notification_id, :utility_token
  before_create :denormalize_username
  before_update :denormalize_username, :if => :username_changed?
  after_create :save_profile, :set_utility_token
  before_destroy :delete_notification

  include Mixins::Indexer::AsyncIndexer

  #ElasticSearch Mappings
  settings :index => { :number_of_shards => 1  } do
    mapping :dynamic => 'false' do
      indexes :username
      indexes :downcased_username
      indexes :first_name
      indexes :last_name
      indexes :gender
      indexes :created_at
      indexes :updated_at
      indexes :full_name
      indexes :permalink
      indexes :sub_text
      indexes :profile_description
      indexes :avatar
    end
  end


  def index_for_elasticsearch
    Resque.enqueue(BackgroundIndexer, 'User', self._id.to_s, :create)
  end

  def is_admin?
    return true if self.admin else false
  end

  def following_lists
    List.in("user_id" => self.following.map {|f| f.user_id}).recent
  end

  def apply_omniauth(omniauth)
    if omniauth['provider'].eql?('facebook')
      authorizations.build(:provider => omniauth['provider'], :uid => omniauth['uid'])
    else
      authorizations.build(:provider => omniauth['provider'], :uid => omniauth['uid'], :twitter_oauth_token => omniauth['credentials']['token'], :twitter_oauth_token_secret => omniauth['credentials']['secret'])
    end
    # build_profile(image: omniauth['info']['image'])
  end

  def password_required?
    (authorizations.empty? || !password.blank?) && super
  end

  def bookmark(list)
    self.bookmarks.create(:type => list.class.to_s,
                          :resource_id => list.id,
                          :name => list.name)
  end

  def unbookmark(list)
    self.bookmarks.where("resource_id" => list.id).destroy
  end

  def has_bookmarked?(list)
    !!bookmarks.where("resource_id" => list.id).first
  end
  
  def bookmarked_lists
    lists = List.in(id: self.bookmarks.map(&:resource_id)).recent
  end

  def connected_with_provider(provider)
    !self.authorizations.where(:provider => provider).first.nil?
  end

  def self.find_first_by_auth_conditions(warden_conditions)
    conditions = warden_conditions.dup
    if login = conditions.delete(:login)
      self.any_of({ :username =>  /^#{Regexp.escape(login)}$/i }, { :email =>  /^#{Regexp.escape(login)}$/i }).first
    else
      super
    end
  end

  def full_name
    if self.first_name.present?
      "#{self.first_name} #{self.last_name}"
    else
      self.username
    end
  end

  def save_profile
    profile = self.build_profile
    profile.save
  end

  def save_omniauth_image(omniauth, save_image=nil)
    #XXX: this shouldn't do two db writes
    self.profile.update_attribute(:image_display, omniauth['provider']) unless save_image.nil?
    self.profile.update_attribute("#{omniauth['provider']}_image", omniauth['info']['image'])
  end

  def auth_ids
    self.authorizations.collect(&:uid)
  end
  
  def notifications_count
    if self.last_notification_id
      count = self.notifications.where(:_id.gt => self.last_notification_id).count
    else
      count = self.notifications.count
    end
  end

  def delete_notification
    users = User.all
    users.each do |user|
      user.notifications.each do |noti|
        noti.delete if noti.body.include?(username)
      end
    end
  end

  def follows?(user)
    following.where("username" => user.username).count > 0 ? true : false
  end

  def to_param
    username
  end

  def store_facebook_info!(auth_hash)
    info = auth_hash.extra.raw_info

    self.email      = info[:email] if info[:email].present?
    self.first_name = info[:first_name]
    self.last_name  = info[:last_name]
    self.birthday   = Date.strptime(info[:birthday], '%m/%d/%Y') if info[:birthday].present?
    self.gender     = info[:gender]

    save!
  end

  def self.find(*args)
    if args.size == 1
      id = args[0]
      if Moped::BSON::ObjectId.legal? id || id.is_a?(Array)
        super
      else
        where(:downcased_username => id.downcase).first ||
          (raise Mongoid::Errors::DocumentNotFound.new(self, :username => id))
      end
    else
      super
    end
  end

  def as_indexed_json(options = {})
    self.as_json(:include => [:profile],
                 :methods => [:permalink, :sub_text, :avatar_url, :title_text, :avatar, :profile_description]).
        merge(:full_name => self.full_name)
  end

  def permalink
    "/#{self.username}"
  end

  # Text thats displayed when a user is searched for using typeahead
  def sub_text
    begin
      "User - #{self.lists.count} lists created."
    rescue => e
      Rails.logger.info("[ERROR] #{e.message} #{e.backtrace}")
      "User - created quite a few lists"
    end
  end
  
  def title_text
    begin
      "#{self.full_name} - #{self.username.to_s}"
    rescue => e
      ""
    end
  end
  
  def profile_description
    begin
      "#{self.profile.description}"
    rescue => e
      ""
    end
  end

  def avatar_url
    unless self.profile.present? && self.profile.avatar.present?
      '/assets/annonymous_user.jpg'
    else
      self.profile.avatar.to_s
    end
  end
  
  def self.reset_avatar_url(user_id)
    user = User.find(user_id)
    # update comments
    list_w_comments = List.where("comments.user_id" => user.id)
    list_w_comments.each do |l|
      list_comments = l.comments.where(:user_id => user.id)
      list_comments.each do |c|
        c.update_attribute(:image, user.profile.avatar)
      end
    end
    # update following
    users_w_following = User.where("following.user_id" => user.id)
    users_w_following.each do |u|
      u.following.where(:user_id => user.id).first.update_attribute(:image, user.profile.avatar)
    end
    # update followers
    users_w_followers = User.where("followers.user_id" => user.id)
    users_w_followers.each do |u|
      u.followers.where(:user_id => user.id).first.update_attribute(:image, user.profile.avatar)
    end 
    # update notifications - this isn't currently possible given the structure of notifications
      
  end
  
  def set_utility_token
    self.update_attribute(:utility_token, Digest::SHA1.hexdigest(self.created_at.to_s))
  end

  private

  def denormalize_username
    self.downcased_username = self.username.downcase
  end
end
