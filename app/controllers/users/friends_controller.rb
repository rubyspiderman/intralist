#TODO: Figure out what to do with this depending how it's used in the UI
class Users::FriendsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :find_provider_friends

  def index
    auth_ids = []
    user_ids = []
    @friends_name = []
    @friends_id = []

    unless @fb_friends.nil?
      @fb_friends.each do |friend|
        auth_ids << friend['id']
        @friends_id << friend['id']
        @friends_name << friend['name']
      end
    end

    unless @twitter_friends.nil?
      @twitter_friends.each do |friend|
        auth_ids << friend.id.to_s
        @friends_id << friend.id.to_s
        @friends_name << friend.screen_name
      end
    end

    intralists = Authorization.where(:uid.in => auth_ids).all
    intralists.each do |id_|
      user_ids << id_.user_id
    end
    @intralists = User.where(:id.in => user_ids)
  end

  def find_friends
    if params[:provider].eql?('facebook')
      list = render_to_string(:partial => 'facebook_list', :locals => {:friends => @fb_friends})
    elsif params[:provider].eql?('twitter')
      list = render_to_string(:partial => 'twitter_list', :locals => {:friends => @twitter_friends})
    end
    render :json => {:list => list}
  end

  private

  def find_provider_friends
    if current_user.connected_with_provider('facebook')
      begin
        fb = Koala::Facebook::API.new(FACEBOOK.get_app_access_token)
        fb_token = current_user.authorizations.where(:provider => 'facebook').first
        @fb_friends = fb.get_connections(fb_token.uid, 'friends')
      rescue
        @fb_friends = []
      end
    end

    if current_user.connected_with_provider('twitter')
      begin
        twitter_token = current_user.authorizations.where(:provider => 'twitter').first
        @twitter_friends = Twitter.followers(twitter_token.uid.to_i).users
      rescue
        @twitter_friends = []
      end
    end
  end
end
