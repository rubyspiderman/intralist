class Bookmark
  include Mongoid::Document
  include Mongoid::Timestamps
  #NOTE: only lists and intralists can be bookmarked
  field :resource_id
  field :name
  field :type
  embedded_in :user

  after_create :inc_count_on_parent
  after_destroy :dec_count_on_parent

  private
  def inc_count_on_parent
    type.constantize.find(resource_id).inc(:bookmarks_count, 1)
  end

  def dec_count_on_parent
    type.constantize.find(resource_id).inc(:bookmarks_count, -1)
  end
end
