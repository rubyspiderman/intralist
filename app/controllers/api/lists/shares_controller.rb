#TODO: QA this
class Api::Lists::ShareController < Api::BaseController
  before_filter :authenticate_user

  def create
    list = List.find(params[:id])
    if params[:provider].eql?('facebook')
      fb = Koala::Facebook::GraphAPI.new(FACEBOOK.get_app_access_token)
      fb_token = current_user.authorizations.where(:provider => 'facebook').first
      fb.put_wall_post(params[:message], {:name => list.name, :link => list_url(list)}, fb_token.uid)
    elsif params[:provider].eql?('twitter')
      token = current_user.authorizations.where(:provider => 'twitter').first
      Twitter.configure do |config|
        config.consumer_key  = 'ujTHYLkc8yYZ5aTuLuSQ'
        config.consumer_secret = 'TyHeqqz3b13Of0g7VJmYWgknW9jvcc5vN7IroJOcMw'
        config.oauth_token = token.twitter_oauth_token
        config.oauth_token_secret = token.twitter_oauth_token_secret
      end
      Twitter.update("#{params[:message]}")
    elsif params[:provider].eql?('email')
      unless params[:email].nil? || params[:email].blank?
        emails = params[:email].split(',')
        emails.each do |email|
          NotificationMailer.share_list(email.gsub(' ', ''), list).deliver
        end
      end
    end
    #TODO: Handle failure case
    head 200
  end
end
