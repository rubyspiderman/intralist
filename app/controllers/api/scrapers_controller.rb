class Api::ScrapersController < ApplicationController
  def create
    results = Scraper.scrape(:url => params[:url])
    render json: results
  end
end
