class UserSerializer < BaseSerializer
  attributes :id, :username, :admin, :notification_count, :follower_count, :following_count
  has_one :profile
  has_many :authorizations
  has_many :notifications
  has_many :followers
  has_many :following
  has_many :lists, :serializer => "ShortListSerializer"
  
  def notifications
    object.notifications.limit(25).order_by(:created_at => :desc)
  end
  def notification_count
    object.notifications.count
  end
  def follower_count
    object.followers.count
  end
  def following_count
    object.following.count
  end
  def lists
    object.lists.trending.limit_5
  end

  
end
