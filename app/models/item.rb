class Item
  include Mongoid::Document
  include Mongoid::Timestamps
  include MongoidVote::Voteable
  field :name
  field :description
  field :picture #DEPRECATED.  TODO: Write a migration to move urls to use image_url
  field :order #DEPRECATED TODO: Write a migration to remove these from old records
  field :link
  field :image_url
  embedded_in :list, :inverse_of => :items

  validates_uniqueness_of :name, :message => "You already have an item on your list by this name"
  validates_length_of :name, :minimum => 1, :too_short => "The name you entered for this item is too short"

  after_save :check_request

  def type
    picture.present? ? "image" : "text"
  end

  protected

  def check_request
    if list.is_a? Response
      # might have to query for for user...
      Notification.request_response(List.find(self.list.id).user, self.list)
    end
  end

end
