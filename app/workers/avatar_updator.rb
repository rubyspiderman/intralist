class AvatarUpdator
  @queue = 'avatar_updator'
  def self.perform(user_id)
    User.reset_avatar_url(user_id)
  end
end