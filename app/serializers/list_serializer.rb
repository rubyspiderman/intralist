#TODO: use a mixin for this and intralist serializer
class ListSerializer < ActiveModel::Serializer
  include ActionView::Helpers::DateHelper
  include Mixins::ListSerializerCommon

  @@attrs = :description, :private, :parent_list_id, :resource_type,
    :parent_list_creator, :intralist_id, :promoted
  attributes *common_attrs.concat(@@attrs)
  has_many :items
  has_many :tags

  def initialize(object, options = {})
    @current_user = options[:current_user]
    #defaults to false
    super
  end

  #XXX: There is some weird intermittent state that the serializer gets in where
  #the nested intralists do not serialize using the IntralistSerializer.  Seems
  #to be a bug with the gem.
  def intralist
    IntralistSerializer.new(object.intralist, {:scope => scope})
  end

  def resource_type
    object.class.to_s
  end

  def tags
    object.tags.map(&:name)
  end
end
