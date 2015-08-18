class Users::UnsubscribeController < ApplicationController 
  def unsubscribe
    user = User.where(email: params[:email], utility_token: params[:token]).first
    if user
      flash[:notice] = "You will no longer receive daily digest emails from Intralst.  You can re-enable this under 'settings' at any point."
      user.update_attribute(:send_notification_email, false)
    else
      
    end
    redirect_to root_path
    # need to add a flash notification here somehow...
  end
end