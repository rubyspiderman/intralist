include ActionView::Helpers::DateHelper
class RequestSerializer < BaseSerializer
  attributes :id, :name, :description, :private, :slug, :comments_count, :created_at, :created_at_in_words
  has_one :user, :serializer => "ShortUserSerializer"
  has_many :comments

  def created_at
    object.created_at.to_i * 1000
  end

  def created_at_in_words
    time_ago_in_words(object.created_at) + " ago"
  end

  def comments
    object.comments.limit(5).order_by(:created_at => :desc)
  end

  def comments_count
    object.comments.count
  end

end
