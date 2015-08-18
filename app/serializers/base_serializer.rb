class BaseSerializer < ActiveModel::Serializer
  def initialize(object, options={})
    super
    @options = options[:serializer_options] || {}
  end
  attr_accessor :options
end

# below is an example of how you can create a filter and pass params into the serializer

# def filter(keys)
#   keys.delete(:following_count) unless options[:with_lists]
#   keys
# end
# 
# render json: user, :serializer_options => {with_lists: true}
