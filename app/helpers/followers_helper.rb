module FollowersHelper

  def in_followers?(followers, user)
    followers.select {|f| f["user_id"] == user.id.to_s }.length >= 1
  end
end
