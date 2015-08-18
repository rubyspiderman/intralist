include ActionView::Helpers::DateHelper
class CommentSerializer < BaseSerializer
  attributes :id, :image, :content, :username, :created_at, :created_at_in_words

  def created_at
    object.created_at.to_i * 1000
  end
  def created_at_in_words
    time_ago_in_words(object.created_at) + " ago"
  end
end
