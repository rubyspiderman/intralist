class Api::FollowersController < Api::BaseController
  def index
    user = User.find(params[:user_id])
    render json: user.followers
  end
end
