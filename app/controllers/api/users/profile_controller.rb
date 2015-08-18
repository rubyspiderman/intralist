class Api::Users::ProfileController < Api::BaseController 
  def update
    user = User.find(params[:user_id])
    # NOTE: This is necessary because update_attributes does not work for remove_banner which is a Carrierwave specific attribute
    unless user == current_user
      return head 403 
    end

    if params[:profile][:remove_banner]
      user.profile.remove_banner = true
      user.profile.save
    else
      status = user.profile.update_attributes(params[:profile])
    end
    render json: user
  end
end
