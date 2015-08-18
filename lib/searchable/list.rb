module Searchable
  module List
    extend ActiveSupport::Concern

    included do
      # Do nothing here
    end

    module ClassMethods
      def typeahead_search(search_query, page = 1, per = 5)
        wildcarded_query = "*#{search_query}*"
        ::List.search(typeahead_querystring(wildcarded_query)).per(per).page(page)
      end

      def typeahead_querystring(query_string)
        {
            :query => {
                :function_score => {
                  :query => {
                    :bool => {
                      :should => [
                        {:query_string => {:fields => ['list.name^5', 'item_names^2'],
                                           :query => query_string
                                          }
                        }
                      ]
                    }
                  },
                  :functions => [
                      {
                          :field_value_factor => {
                              :field => 'up_count',
                              :modifier => 'none',
                              :factor => '1.5'
                          }
                      }
                  ],
                  :score_mode => 'sum',
                  :boost_mode => 'sum'
                }
            }
        }
      end
    end
  end
end