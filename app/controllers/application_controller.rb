class ApplicationController < ActionController::Base
  after_filter :store_location
  protect_from_forgery

  def store_location
    # make sure we don't do infinite redirects on /users/*
    session[:previous_url] = request.fullpath unless request.fullpath =~ /\/users|api/
  end

  def after_sign_in_path_for(resource)
    session[:previous_url] || root_path
  end

  protected

  def check_admin
    unless user_signed_in? && current_user.admin?
      redirect_to root_path
    end
  end
  
  def avatar_url(user)
    case user.profile.image_display
    when "facebook"
      thumb_img = user.profile.facebook_image
    when "twitter"
      thumb_img = user.profile.twitter_image
    when "upload"
      thumb_img = user.profile.image.thumb.url
    else
      thumb_img = ActionController::Base.helpers.asset_path "annonymous_user.jpg"
    end
    return thumb_img
  end
end
