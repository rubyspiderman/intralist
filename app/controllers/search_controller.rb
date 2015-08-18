require 'search'
class SearchController < ApplicationController

  def show
    query_string = params[:q]
    facets = [:user, :list, :intralist]
    page = params[:page] || 1

    if params[:f].present? && Search::FACETS.include?(params[:f].strip.to_sym)
      facets = [params[:f].to_sym].flatten
    end

    respond_to do |format|
      format.json {
        results = ::Search.for(query_string, facets, page)
        render :json => {:results => results}, :status => :ok
      }

      format.html {
        paginatable_entity = @users

        if facets.include?(:user)
          @users = User.typeahead_search(query_string, page).results.map(&:_source)
          paginatable_entity = @users if paginatable_entity.nil?
        end

        if facets.include?(:list)
          @lists = List.typeahead_search(query_string, page).results.map(&:_source)
          paginatable_entity = @lists if paginatable_entity.nil? || paginatable_entity.length < @lists.length
        end

        if facets.include?(:intralist)
          @intralists = Intralist.typeahead_search(query_string, page).results.map(&:_source)
          paginatable_entity = @intralists  if  paginatable_entity.nil? || paginatable_entity.length < @intralists.length
        end


        @paginatable_entity = Kaminari.paginate_array(paginatable_entity).page(page).per(5)
      }
    end
  end
end
