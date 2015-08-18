class Api::UsersController < Api::BaseController

  def show
    user = User.find(params[:id])
    render json: user
  end

  def index
    search_term = params[:search]
    users = User.typeahead_search(search_term, 1).map { |result| result["_source"]}
    render json: users.to_json({only: [:_id, :username, :full_name, :avatar_url]})
  end

  def update
    user = User.find(params[:id]).update_attributes(params[:user])
    render json: user
  end
end
