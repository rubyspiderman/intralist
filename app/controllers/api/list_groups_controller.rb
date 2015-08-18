class Api::ListGroupsController < Api::BaseController

  def index
    list_groups = if params[:filter]
      filter_type = params[:filter]
      case filter_type
      when "top"
        ListGroup.trending(params[:page]) #Discuss - Should this potentially show the same list group twice if 2 lists with the same name have many upvotes?
      when "tag"
        #FIXME: Tags need to have their own collection.  Add index for this as well.
        ListGroup.where(:"tags.#{params[:tag]}".exists => true).desc(:created_at).page(params[:page])
      when "user"
        ListGroup.desc(:updated_at).where(:user_ids.in => [params[:user_id]]).page params[:page]
      when "recent"
        ListGroup.desc(:updated_at).page(params[:page])
      when "intralists"
        Intralist.all.recent.page params[:page]
      when "my-feed"
        groups = ListGroup.my_feed(current_user, params[:page])
        groups.map { |group| ListGroupSerializer.new(group, {:my_feed => true, :current_user => current_user}) }
      when "trending"
        ListGroup.trending(params[:page]) #Discuss - Should this potentially show the same list group twice if 2 lists with the same name have many upvotes?
      end
    elsif params[:query]
      List.search(params)
    end

    render :json => list_groups
  end


  #/requests
  #Look up a list group via a list slug
  def show
    #TODO: requests
    if params[:type] == "request"
      req = Request.find(params[:id])
      list_group = RequestListGroupSerializer.new(req.list_group, {:include_related_lists => true, :current_user => current_user})
    else
      list = List.find(params[:id])
      list_group = ListGroupSerializer.new(list.list_group, {:include_related_lists => true, :current_user => current_user})
    end

    render json: list_group
  end

end
