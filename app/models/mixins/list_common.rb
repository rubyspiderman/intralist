module Mixins::ListCommon
  extend ActiveSupport::Concern

  included do
    include Mongoid::Document
    include Mongoid::Timestamps
    #TODO:  Remove down_count field since we don't have downvotes
    include MongoidVote::Voteable
    embeds_many :comments, :as => :commentable

    field :name
    field :description
    field :slug
    field :content_source_url
    field :content_source_name
    field :bookmarks_count, :type => Integer, :default => 0

    #TODO: Clean out upvote/downvote fields if we're getting rid of that stuff.  Rename vote_count to likes_count
    alias :likes_count :vote_count

    def to_param
      slug
    end
    #TODO: Cleanup - voteable module only returns "User Ids"
    def first_three_voters
      self.up_voters.first(3).map {|user_id| User.find(user_id).username }
    end

    def find_comment(id)
      if Moped::BSON::ObjectId.legal?(id) || id.is_a?(Array)
        self.comments.find(id)
      else
        self.comments.where(:cid => id).first ||
          (raise Mongoid::Errors::DocumentNotFound.new(self, :id => id))
      end
    end

  end
end
