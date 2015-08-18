class Api::Users::BookmarksController < Api::BaseController
  def show
    user = User.find(params[:user_id])
    render json: user.bookmarked_lists
  end
end
