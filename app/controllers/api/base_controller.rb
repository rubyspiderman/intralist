class Api::BaseController < ApplicationController

  rescue_from 'Mongoid::Errors::DocumentNotFound' do |e|
    puts e.backtrace.join("\n")
    head :not_found
  end

  private

  def list
    @list ||= if params[:intralist]
      Intralist.find(params[:list_id])
    else
      List.find(params[:list_id])
    end
  end
end
