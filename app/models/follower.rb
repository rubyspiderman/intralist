class Follower
  include Mongoid::Document
  include Mongoid::Timestamps
  field :user_id
  field :username
  field :image
  embedded_in :user

  def parent
    User.find(self.user_id)
  end

end
