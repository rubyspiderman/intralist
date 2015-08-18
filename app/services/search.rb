class Search
  attr_accessor :query, :search_request, :models, :results
  Elasticsearch::Model::Response::Records

  FACETS = [:user, :list, :intralist]

  def initialize(query, data_stores = [:list])
    @query = query
    @models = data_stores.map{|model| model.to_s.capitalize }
    @results = []
  end

  def self.for(q, data_stores, page = 1, typeahead = true)
    @search_request = Search.new(q, data_stores)

    @search_request.results = @search_request.models.map do |model|
      if typeahead
        (model.constantize.typeahead_search("#{@search_request.query}", page, 2)).results.entries
      else
        (model.constantize.typeahead_search("#{@search_request.query}", page, 5)).results.entries
      end
    end.flatten

    typeahead ? @search_request.as_typeahead : @search_request.as_standard_search
  end

  def as_standard_search
    self.results.flatten
  end

  def as_typeahead
    self.results.map(&:_source).map do |object|
      {
        :_id => object._id,
        :type => object.class.to_s,
        :title => object.title_text,
        :type_icon => object.icon_url,
        :type_url => object.permalink,
        :sub_text => object.sub_text
      }
    end
  end
end
