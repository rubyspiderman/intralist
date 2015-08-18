class Api::Lists::LikesController < Api::BaseController
  before_filter :authenticate_user!

  #XXX: The following is used for both create and destroy so that less logic can be used on both the front and backend
  def create
    list.upvote_toggle(current_user)
    list.save!
    head :ok
  end
end
