class BackgroundIndexer
  @queue = 'background_indexer'

  def self.perform(klass_name, id, op = :create)
    indexable_entity = klass_name.constantize.find(id)

    if op.to_sym == :create
      indexable_entity.__elasticsearch__.index_document
    elsif op.to_sym == :update
      indexable_entity.__elasticsearch__.update_document
    elsif op.to_sym == :destroy
      indexable_entity.__elasticsearch__.destroy_document
    end
    indexable_entity.class.__elasticsearch__.refresh_index!
  end
end
