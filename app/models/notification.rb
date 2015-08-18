class Notification
  include Mongoid::Document
  include Mongoid::Timestamps
  field :body, type: String
  field :image
  field :group_type
  embedded_in :user

  default_scope order_by(:created_at => :desc)

  scope :daily, where(:created_at.gte => Date.today)
  scope :weekly, where(:created_at.gte => (Date.today - 30))
  
  def self.new_follower(user, follower)
    message = "<a href='#{HOSTNAME}/#{follower.id}/profile'>#{follower.username}</a> is now following you"
    user.notifications.create(body: message, image: follower.profile.avatar, created_at: Time.now(), :group_type => "activity")
  end

  def self.new_comment(user, commentor, list)
    message = "<a href='#{HOSTNAME}/#{commentor.username}'>#{commentor.username}</a> just commented on your list, <a href='#{HOSTNAME}/lists/#{list.slug}'>#{list.name}</a>"
    user.notifications.create(body: message, image: commentor.profile.avatar, created_at: Time.now(), :group_type => "activity")
  end

  def self.new_mention(mentions, commentor, list)
    mentions.each do |mention|
      message = "<a href='#{HOSTNAME}/#{commentor.username}'>#{commentor.username}</a> mentioned you in a comment on the list, <a href='#{HOSTNAME}/lists/#{list.slug}'>#{list.name}</a>"
      mention.notifications.create(body: message, image: commentor.profile.avatar, created_at: Time.now(), :group_type => "activity")
    end
  end

  def self.new_friend_registered(user, friend, provider)
    message = "Your friend #{friend.first_name} #{friend.last_name} from #{provider} just registered on Intralist as <a href='#{HOSTNAME}/#{friend.username}/'>#{friend.username}</a>"
    user.notifications.create(body: message, image: friend.profile.avatar, created_at: Time.now(), :group_type => "friend")
  end
  
  def self.you_have_friends(user, friends, provider)
    # TODO: refactor this.  Shouldn't need separate but the same things here for Facebook / Twitter
    if friends.count > 1
      friend_names = {}
      if provider == "facebook"
        friends[0..4].each do |f|
          full_name = "#{f.user.first_name} #{f.user.last_name}"
          friend_names[full_name] = f.user.downcased_username
        end
      # TODO: Keep this for now for Twitter even though Twitter I don't think works
      else
        friends[0..4].each do |f|
          friend_names << f[:name]
        end
      end
      friends_linked = friend_names.map {|k, v| "<a href='/#{v}'>#{k}</a>"}.join(", ")
      message = "You have #{friends.count} #{'friends'.pluralize(friends.count)} from #{provider}</a> that are already using Intralist including #{friends_linked}."
    else
      if provider == "facebook"
        message = "Your friend #{friends.first.user.first_name} #{friends.first.user.last_name} from #{provider} is already using Intralist as <a href='/#{friends.first.user.username}'>#{friends.first.user.username}</a>."
      else
        message = "Your friend '#{friends[0][:name]}' from #{provider} is already using Intralist.  <a href='/#{user.username}/friends'>Manage your connections</a>."
      end
    end
    user.notifications.create(body: message, image: friends.first.user.profile.avatar, created_at: Time.now(), :group_type => "friend")
  end

  def self.request_response(responder, list)
    request_user = list.request.user
    message = "Your friend <a href='#{HOSTNAME}/#{responder.username}'>#{responder.username}</a> just responded to your '<a href='#{HOSTNAME}/requests/#{list.request.slug}'>#{list.request.name}</a>' request"
    request_user.notifications.create(body: message, image: responder.profile.avatar, created_at: Time.now(), :group_type => "activity")
  end

  def self.new_request(creator, request, target_user)
    message = "<a href='#{HOSTNAME}/#{creator.username}'>#{creator.username}</a> just requested a list for '#{request.name}.' <a href='#{HOSTNAME}/requests/#{request.slug}'>Respond</a>."
    target_user.notifications.create(body: message, image: creator.profile.avatar, created_at: Time.now(), :group_type => "request")
  end

  def self.list_copied(current_user, list, copied_from_user)
    message = "<a href='#{HOSTNAME}/#{current_user.username}'>#{current_user.username}</a> just copied your list, '<a href='#{HOSTNAME}/lists/#{list.slug}'>#{list.name}</a>'.  Did they do it justice?"
    copied_from_user.notifications.create(body: message, image: current_user.profile.avatar, created_at: Time.now(), :group_type => "activity")
  end

  def self.liked_list(current_user, list)
    message = "<a href='#{HOSTNAME}/#{current_user.username}/profile'>#{current_user.username}</a> just liked your list,'<a href='#{HOSTNAME}/lists/#{list.slug}'>#{list.name}</a>'.  That must feel fuzzy"
    list.user.notifications.create(body: message, image: current_user.profile.avatar, created_at: Time.now(), :group_type => "activity")
  end

  def self.clear_notifiations(user)
    user.notifications.delete_all
  end
end
