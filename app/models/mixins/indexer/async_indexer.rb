module Mixins::Indexer::AsyncIndexer
  extend ActiveSupport::Concern

  included do
    after_create :async_create_index
    after_update :async_update_index
    after_destroy :async_destroy_index

    def async_create_index
      Resque.enqueue(BackgroundIndexer, self.class.to_s, self.id.to_s, :create)
    end

    def async_update_index
      Resque.enqueue(BackgroundIndexer, self.class.to_s, self.id.to_s, :update)
    end

    def async_destroy_index
      Resque.enqueue(BackgroundIndexer, self.class.to_s, self.id.to_s, :destroy)
    end
  end

  module ClassMethods
  end
end

