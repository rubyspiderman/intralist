class Api::Lists::ListsController < Api::BaseController
  before_filter :authenticate_user!, :only => [:create, :update, :destroy]
  #TODO: test auth'd endpoints
  def index
    lists = if params[:filter]
      filter_type = params[:filter]
      case filter_type
      when "promoted"
        lists = List.where(promoted: true).recent.page params[:page]
      end
    elsif params[:query]
      List.search(params)
    end

    render :json => lists
  end

  def create
    options = {
      :name               => params[:name],
      :description        => params[:description],
      :user_id            => current_user.id,
      :cid                => params[:cid],
      :parent_list_id     => params[:parent_list_id],
      :intralist_id       => params[:intralist_id],
      :content_source_url => params[:content_source_url]
    }

    list = if params[:request_id]
      options[:request_id] = params[:request_id]
      Response.new(options)
    else
      List.new(options)
    end

    if tags = params[:tags]
      tags.each do |tag|
        list.tags.new(:name => tag.downcase)
      end
    end

    params[:items].each_with_index do |item, i|
      list.items.new(:name => item[:name],
                     :description => item[:description],
                     :link => item[:link],
                     :image_url => item[:image_url])
    end

    if list.save
      #Q: Should the creator get a copy notification if they create a list with the same name as another?  Probably
      #TODO:  Move this stuff into after_create
      if params[:parent_list_id]
        copied_from_user = List.find(params[:parent_list_id]).user
        unless copied_from_user == current_user
          Notification.list_copied(current_user, list, copied_from_user)
        end
      end
      render json: list
    else
      head 400
    end
  end

  def update
    list = List.find(params[:id] || params[:cid])
    head 403 unless current_user.id == list.user.id

    if tags = params[:tags]
      old_tags = list.tags.to_a.map(&:name)
      list.tags = []

      tags.each do |tag|
        list.tags.new(:name => tag.downcase)
      end

      list.list_group.update_tags(old_tags, params[:tags])
    end

    if list.update_list(params)
      render json: list
    else
      head 400
    end
  end


  def destroy
    list = List.find(params[:id])
    head 403 unless current_user.id == list.user.id

    status = list.destroy ? 200 : 400
    head status
  end
end
