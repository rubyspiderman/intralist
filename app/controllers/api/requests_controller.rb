class Api::RequestsController < Api::BaseController
  before_filter :authenticate_user!, :only => [:create, :update, :destroy]
  #TODO: Need to be able to get requests by user
  #TODO: Test auth'd reqs
  def index
    if params[:filter]
      case params[:filter]
      when "by_me"
        requests = Request.where(:user_id => current_user.id)
      when "recent"
        requests = Request.limit_5
      when "for_me"
        requests = []
        current_user.followers.each do |f|
          f.parent.requests.each do |r|
            requests << r
          end
        end
        requests = Request.in(:user_id => current_user.following.map {|f| f.user_id})
      end
    else
      #TODO: change this to paginate
      requests = Request.limit_5
    end

    render json: requests
  end

  def create
    request = Request.new(params[:request])
    request.user_id = current_user.id
    if params[:tags]
      tags = params[:tags][:name]
      tags.gsub("\s","").split(",").each do |tag_name|
        request.tags.new(:name => tag_name.downcase)
      end
    end
    if request.save
      render json: request
    else
      head 400
    end
  end

  def show
    request = Request.find(params[:id])
    render json: request
  end

  def update
    request = Request.where(:id => params[:id],
                            :user_id => current_user.id).first
    head 404 unless request

    status = request.update_attributes(params[:request]) ? 200 : 400
    head status
  end

  def destroy
    request = Request.where(:id      => params[:id],
                            :user_id => current_user.id).first
    head 404 unless list

    status = request.destroy ? 200 : 400
    head status
  end
end
