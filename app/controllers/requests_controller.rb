class RequestsController < ApplicationController
  respond_to :html, :xml, :json
  before_filter :authenticate_user!, :except => ["index", "show"]
  layout "angular"

  def index
    render :inline => "", :layout => true
  end
  def show
    @list = Request.find(params[:id])
    render :inline => "", :layout => true
  end 
end