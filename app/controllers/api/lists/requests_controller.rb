class Api::Lists::RequestsController < Api::BaseController
  before_filter :authenticate_user!, except: [:show]

  def index
    requests = if params[:filter]
      filter_type = params[:filter]
      #TODO: move filtering and all variations into model
      case filter_type
      when "by_me"
        Request.where(:user_id => current_user.id)
      when "for_me"
        current_user.followers.each do |f|
          f.parent.requests.each do |r|
            @requests << r
          end
        end
        Request.in(:user_id => current_user.following.map {|f| f.user_id})
      else
        current_user.requests
      end
    else
      current_user.requests
    end
    render json: requests
  end

  def create
    @request = Request.new(params[:request])
    @request.user_id = current_user.id
    if params[:tags]
      tags = params[:tags][:name]
      tags.gsub("\s","").split(",").each do |tag_name|
        @request.tags.new(:name => tag_name.downcase)
      end
    end
    respond_with do |f|
      f.html do
        if request.xhr?
          if @request.save
            render :partial => 'request', :locals => {:request => @request}, :layout => false, :status => :created
            notify_followers
          end
        end
      end
    end
  end

  def show
    request_id = params[:id]
    @request = Request.find(request_id)
    # @request = current_user.requests.new
    @lists = List.where(:request_id => request_id)
    @recent_requests = Request.limit_5
    render_sign_up_page unless current_user
  end

  def update
    @request = List.find(params[:id])
    if params[:request]
      @request.update_attributes(params[:request])
    end
    redirect_to @request
  end

  protected

  def render_sign_up_page
    @user = User.new
    render "static/index", layout: "home"
  end

  def notify_followers
    current_user.followers.each do |f|
     Notification.new_request(current_user, @request, f.parent)
    end
  end
end
