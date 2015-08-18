class ListGroupSerializer < BaseSerializer
  attributes :name, :related_lists, :lists
  attr_accessor :include_related_lists

  has_many :lists
  # has_many :users

  #FIXME: Shouldn't need to pass in the serializer name here... what's the deal
  has_one :intralist, :serializer => "IntralistSerializer"
  #NOTE: belongs_to not defined in serializers.  Maybe it will be in a future
  #release?
  def initialize(object, options = {})
    @include_related_lists = options[:include_related_lists]
    @my_feed = options[:my_feed]
    @current_user = options[:current_user]
    super
  end

  alias_method :original_lists, :lists
  def lists
    if @my_feed
      _lists = original_lists.to_a.dup
      _list = _lists.detect do |list|
        @current_user.following.map(&:user_id).include? list.user_id
      end
      _lists.delete(_list)
      _lists.unshift(_list)
    else
      original_lists
    end
  end

  def related_lists
    return unless self.include_related_lists
    # TODO: Let's compact this as we only need to see name really, not list items.
    # NOTE: We may be making too many calls here to return a list?  a) list, b) related lists, c) intralists
    List.related_by_tags_to(self.lists.first)
  end

end
