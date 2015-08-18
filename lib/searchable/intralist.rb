module Searchable
  module Intralist
    extend ActiveSupport::Concern

    included do
      # Do nothing here
    end

    module ClassMethods
      def typeahead_search(search_query, page = 1, per = 5)
        wildcarded_query = "*#{search_query}*"
        ::Intralist.search(typeahead_querystring(wildcarded_query)).per(per).page(page)
      end

      def typeahead_querystring(query_string)
        {
            :query => {
                :function_score => {
                  :query => {
                      :bool => {
                          :should => [
                              {:query_string => {
                                  :default_field => 'intralist.name',
                                  :query => query_string
                              }
                              },
                              {:query_string => {:default_field => 'intralist.intralist_items.name',
                                                 :query => query_string}
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