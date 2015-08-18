class Authorization
  include Mongoid::Document
  field :uid
  field :provider
  #TODO: Convert twitter_oauth_token in a generic oauth_token field
  field :twitter_oauth_token
  field :twitter_oauth_token_secret
  #TODO: USed to store facebook oauth access token expiry period
  field :expires_at, :type => Integer # Timestamp

  # embedded_in :users
  belongs_to :user

  attr_accessible :uid, :provider, :twitter_oauth_token, :twitter_oauth_token_secret
  validates_uniqueness_of :uid

  def provider_name
    if provider == 'open_id'
      "OpenID"
    else
      provider.titleize unless provider.nil?
    end
  end
  
  def notify_friend
    friends_id = []
    if self.provider.eql?('facebook')
      fb = Koala::Facebook::API.new(FACEBOOK.get_app_access_token)
      friends = fb.get_connections(self.uid, 'friends')
      friends.each do |friend|
        friends_id << friend['id'].to_s
      end
    elsif self.provider.eql?('twitter')
      Twitter.configure do |config|
        config.consumer_key  = 'ujTHYLkc8yYZ5aTuLuSQ'
        config.consumer_secret = 'TyHeqqz3b13Of0g7VJmYWgknW9jvcc5vN7IroJOcMw'
        config.oauth_token = self.twitter_oauth_token
        config.oauth_token_secret = self.twitter_oauth_token_secret
      end

      friends = Twitter.followers(self.uid.to_i).users
      friends.each do |friend|
        friends_id << friend.id.to_s
      end
    end

    intralists = Authorization.where(:uid.in => friends_id).all
    unless intralists.empty? || intralists.nil?
      intralists.each do |i|
        Notification.new_friend_registered(i.user, self.user, self.provider)
      end
    end
  end
end
