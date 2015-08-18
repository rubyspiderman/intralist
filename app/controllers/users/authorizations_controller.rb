class Users::AuthorizationsController < ApplicationController
  before_filter :authenticate_user!, :except => 'create'

  def index
    @auths = current_user.authorizations
  end

  def create
    omniauth = request.env["omniauth.auth"]
    # raise omniauth['provider']
    # auth = User.where('authorizations.provider' => omniauth['provider'],
    #                            'authorizations.uid' => omniauth['uid']).first

    auth = Authorization.where(:provider => omniauth['provider'], :uid => omniauth['uid']).first

    if auth
      if user_signed_in? && auth.user == current_user
        auth.update_attributes(:twitter_oauth_token => omniauth['credentials']['token'], :twitter_oauth_token_secret => omniauth['credentials']['secret']) if omniauth['provider'].eql?('twitter') && (auth.twitter_oauth_token.nil? ||  auth.twitter_oauth_token_secret.nil?)
        current_user.save_omniauth_image(omniauth)
        auth.notify_friend
        flash[:notice] = "Authentication successful."
        redirect_to root_url
      elsif user_signed_in? && auth.user != current_user
        redirect_to root_path, :notice => "Authentication Failed. Account is connected to other user."
      else
        if omniauth[:provider] == 'facebook'
          auth.update_attributes(:twitter_oauth_token => omniauth['credentials']['token'],
                                :twitter_oauth_token_secret => omniauth['credentials']['secret'],
                                :expires_at => omniauth['credentials'][:expires_at])
        else
          auth.update_attributes(:twitter_oauth_token => omniauth['credentials']['token'], :twitter_oauth_token_secret => omniauth['credentials']['secret']) if omniauth['provider'].eql?('twitter') && (auth.twitter_oauth_token.nil? ||  auth.twitter_oauth_token_secret.nil?)
        end

        respond_to do |format|
          format.html {
                        flash[:notice] = "Signed in successfully."
                        sign_in_and_redirect(:user, auth.user)
                      }

          format.json {
            sign_in(:user, auth.user)
            render :json => {:request_status => 'success',
                                         :user_exists => true,
                                         :data => auth.user
                                        }
                      }
        end
      end
    elsif current_user
      if omniauth['provider'].eql?('facebook')
        current_user.authorizations.create!(:provider => omniauth['provider'], :uid => omniauth['uid'])
        current_user.store_facebook_info!(omniauth)
      elsif omniauth['provider'].eql?('twitter')
        current_user.authorizations.create!(:provider => omniauth['provider'], :uid => omniauth['uid'], :twitter_oauth_token => omniauth['credentials']['token'], :twitter_oauth_token_secret => omniauth['credentials']['secret'])
      end
      current_user.authorizations.where(:provider => omniauth['provider']).first.notify_friend
      current_user.save_omniauth_image(omniauth)
      flash[:notice] = "Authentication successful."
      redirect_to root_url
    else
      #XXX: If extra is included for twitter, a cookie overflow will result
      session[:omniauth] = if omniauth['provider'].eql?('facebook')
        omniauth
      else
        omniauth.except('extra')
      end

      respond_to do |format|
        format.html { redirect_to new_user_registration_url }
        format.json { render :json => {:request_status => 'success',
                                       :data => session[:omniauth].except('credentials')}
                    }
      end
    end
  end

  def destroy
    @auth = current_user.authorizations.where(:provider => params[:provider]).delete
    current_user.profile.update_attribute("#{params[:provider]}_image", nil)
    redirect_to root_path, :notice => "#{params[:provider].titleize} disconnected to your account"
  end
end
