class Api::Lists::CopiesController < Api::BaseController

  #TODO:This should take pagination and offset params when necessary
  #TODO: Technically, the CRUD of all copies should be in here were this all purely RESTFUL.  Could share code with the lists controller.
  def index
    copies = list.copies
    copies = copies[5, (copies.length-1)]

    render json: copies
  end
end
