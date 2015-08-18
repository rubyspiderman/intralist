class ShortUserSerializer < BaseSerializer
  attributes :username, :avatar_url, :id

  def avatar_url
    object.profile.avatar
  end
end
