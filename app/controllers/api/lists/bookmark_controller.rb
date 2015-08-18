#FIXME: Not sure why this has to be singular as opposed to LikesController
class Api::Lists::BookmarkController < Api::BaseController
  before_filter :authenticate_user!

  #XXX: The following is used for both create and destroy so that less logic can be used on both the front and backend
  def create
    if current_user.has_bookmarked?(list)
      current_user.unbookmark(list)
    else
      current_user.bookmark(list)
    end
    head :ok
  end
  def index
    lists = List.in(id: current_user.bookmarks.map{|r| r.resource_id})
    render json: lists
  end
end
