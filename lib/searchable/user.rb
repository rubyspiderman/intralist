module Searchable
  module User
    extend ActiveSupport::Concern

    included do
      # Do nothing here

    end

    module ClassMethods
      def typeahead_search(search_query, page = 1, per = 5)
        wildcarded_query = "#{search_query}*"
        ::User.search(typeahead_querystring(wildcarded_query)).per(per).page(page)
      end

      def typeahead_querystring(query_string)
        {
            :query => {
                :bool => {
                    :should => [
                        {:wildcard => {'user.first_name' => query_string.downcase}},
                        {:wildcard => {'user.last_name' => query_string.downcase}},
                        {:wildcard => {'user.username' => query_string}},
                        {:query_string => {
                            :default_field => 'user.full_name',
                            :query => query_string
                        }}
                    ]
                }
            }
        }
      end
    end
  end
end