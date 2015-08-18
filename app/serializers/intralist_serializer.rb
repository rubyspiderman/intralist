class IntralistSerializer < BaseSerializer
  include Mixins::ListSerializerCommon
  @@attrs = [:items, :is_intralist]
  attributes *common_attrs.concat(@@attrs), :updated_at_in_words, :list_count

  #XXX: Even though intralists store items with a count of one, they should only
  #display those with a count of 2 or more
  def items
    object.intralist_items.default.map do |item|
      IntralistItemSerializer.new(item)
    end
  end

  def list_count
    object.lists.count
  end

  def is_intralist; true; end

  def updated_at_in_words
    if object.updated_at
      time_ago_in_words(object.updated_at) + " ago"
    end
  end

end
