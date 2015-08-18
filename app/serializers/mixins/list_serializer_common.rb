module Mixins::ListSerializerCommon
  include ActionView::Helpers::DateHelper
  extend ActiveSupport::Concern

  included do
    has_one :user, :serializer => "ShortUserSerializer"
    has_many :comments

    def current_user
      scope || @current_user
    end
    def created_at
      object.created_at.to_i * 1000
    end

    def created_at_in_words
      if object.created_at
        time_ago_in_words(object.created_at) + " ago"
      end
    end

    def liked_by_me
      !!object.current_vote(current_user) if current_user
    end

    def voters
      voters = object.first_three_voters
      if liked_by_me
        if voters.index(current_user.username)
          voters.delete(current_user.username) 
        end
        voters.unshift("You")
      end
      if object.likes_count > 3
        others_count = object.likes_count - voters.count
        voters.push("#{others_count} others")
      end
      voters.to_sentence
    end

    def bookmarked_by_me
      scope.has_bookmarked?(object) if scope
    end

    def comments_count
      object.comments.count
    end

    def comments
      object.comments.last(5)
    end
  end


  module ClassMethods
    def common_attrs
      [:id, :name, :content_source_url, :content_source_name, :bookmarks_count, :likes_count, :comments_count, :liked_by_me, :voters , :bookmarked_by_me, :slug, :created_at, :created_at_in_words]
    end
  end

end
