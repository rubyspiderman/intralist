class Api::IntralistsController < Api::BaseController
  before_filter :authenticate_user!, :only => :create

  def index
    intralists = Intralist.all
    render json: intralists
  end

  def show
    intralist = Intralist.find(params[:id])
    render json: intralist
  end
end
