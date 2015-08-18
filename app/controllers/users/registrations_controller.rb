class Users::RegistrationsController < Devise::RegistrationsController

  def create
    super
    if resource.valid?
      if session[:omniauth]
        if session[:omniauth]['provider'].eql?('facebook')
          resource.store_facebook_info!(session[:omniauth])
        end

        #XXX: User object is in an invalid state after next line, cannot be saved
        auth = @user.apply_omniauth(session[:omniauth])
        auth.save
        auth.notify_friend

        resource.save_omniauth_image(session[:omniauth], true)

        find_provider_friends
        # TODO:  This needs a serious refactoring below...
        # TODO:  HOLY CRAP.  This does need a serious refactoring.  I'm thinking you can pass intralist_friends to Notification.you_have_friends
        unless @fb_friends.nil?
          facebook_friends = @fb_friends.collect {|f| f["id"]}
          intralist_friends = Authorization.where(:uid.in => facebook_friends, :provider => "facebook").all
          if intralist_friends.count >= 1
            Notification.you_have_friends(resource, intralist_friends, "facebook") 
          end
        end
        unless @twitter_friends.nil?
          logger.error "We have #{@twitter_friends.count} friends..."
          twitter_friends = @twitter_friends.map {|i| {
            name: i["screen_name"],
            id: i["id"].to_s
            }
          }
          friend_ids = twitter_friends.collect {|t| t[:id]}
          friend_ids = friend_ids.map(&:to_s)
          intralist_friends = Authorization.where(:uid.in => friend_ids, :provider => "twitter").all
          intralist_friend_ids = intralist_friends.collect {|k| k.uid}
          # this isn't working yet.  Time to take a break
          your_friends = twitter_friends.reject {|k| !intralist_friend_ids.include?(k[:id])}
          if your_friends.count >= 1
            Notification.you_have_friends(resource, your_friends, "twitter") 
          end
        end
      end
    end
    session[:omniauth] = nil unless @user.new_record?
  end

  def update
    @user = User.find(current_user.id)

    successfully_updated = if needs_password?(@user, params)
                             @user.update_attributes(params[:user])
                           else
                             params[:user].delete(:current_password)
                             @user.update_without_password(params[:user])
                           end

    if successfully_updated
      profile = @user.profile
      profile.save!
      set_flash_message :notice, :updated
      # Sign in the user bypassing validation in case his password changed
      sign_in @user, :bypass => true
      redirect_to after_update_path_for(@user)
    else
      render "edit"
    end
  end

  private

  # check if we need password to update user data
  # ie if password or email was changed
  # extend this as needed
  def needs_password?(user, params)
    user.email != params[:user][:email] ||
      !params[:user][:password].blank?
  end

  def clean_up_passwords(resource)
    return if session[:omniauth]
    resource.password = resource.password_confirmation = nil
  end

  def build_resource(*args)
    super
    if session[:omniauth]
      @user.apply_omniauth(session[:omniauth])
    end
  end

  def find_provider_friends
    if resource.connected_with_provider('facebook')
      begin
        fb = Koala::Facebook::API.new(FACEBOOK.get_app_access_token)
        fb_token = resource.authorizations.where(:provider => 'facebook').first
        @fb_friends = fb.get_connections(fb_token.uid, 'friends')
      rescue
        @fb_friends = []
      end
    end

    if resource.connected_with_provider('twitter')
      begin
        twitter_token = resource.authorizations.where(:provider => 'twitter').first
        @twitter_friends = Twitter.followers(twitter_token.uid.to_i).users
      rescue
        @twitter_friends = []
      end
    end
  end
end
