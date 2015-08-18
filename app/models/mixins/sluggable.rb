module Mixins::Sluggable
  extend ActiveSupport::Concern

  included do
    before_create :generate_slug
    before_update :generate_slug, :if => lambda { |list| list.name_changed? }

    validates_uniqueness_of :slug, :on => :create, :allow_nil => true

    MAX_SLUG_LENGTH = 50

    def self.find(*args)
      if args.size == 1
        id = args[0]
        if Moped::BSON::ObjectId.legal?(id) || id.is_a?(Array)
          super
        elsif id.is_a? String
          if id =~ /^[\d\w]{1,9}$/
            list = where(:cid => id).first
            return list if list
            #fallback to a slug in the edge-case whereby the cid is actually a slug
          end
          where(:slug => id.downcase).first ||
            (raise Mongoid::Errors::DocumentNotFound.new(self, :id => id))
        else
          raise "invalid type"
        end
      else
        super
      end
    end

    def permalink
      "/#{self.class.to_s.downcase.pluralize}/#{self.slug}"
    end

    private

    def generate_slug
      sequence = 0
      generated_slug = name.slice(0, MAX_SLUG_LENGTH).slugize

      while(self.class.collection.where(:slug => generated_slug).count > 0) do
        sequence += 1
        truncated_slug = name.slice(0, (MAX_SLUG_LENGTH - sequence.to_s.length))
        generated_slug = [truncated_slug, sequence].join(' ').slugize
      end

      self.slug = generated_slug
    end
  end
end
