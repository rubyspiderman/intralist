class Api::Users::FollowsController < Api::BaseController
  before_filter :authenticate_user!, :only => [:create, :destroy]

  def index
    user = User.find(params[:user_id])
    render json: user.following
  end

  def create
    current_user = User.find(params[:user_id]) 
    follower = User.find(params[:follower_id])
    current_user.following.find_or_create_by(user_id: follower.id, username: follower.username, image: avatar_url(follower))
    # FIXME: this could be in an after_save callback
    follower.followers.find_or_create_by(user_id: current_user.id, username: current_user.username, image: avatar_url(current_user))
    Notification.new_follower(follower, current_user)
    head 200
  end

  def destroy
    follower_id = params[:id]
    current_user.following.where(user_id: follower_id).destroy
    User.find(follower_id).followers.where(user_id: current_user.id).destroy
    head 200
  end
end
