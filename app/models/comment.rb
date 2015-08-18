class Comment
  include Mongoid::Document
  include Mongoid::Timestamps
  belongs_to :user
  field :username
  field :image
  field :content
  field :cid
  #NOTE: commentable refers to either a list or intralist
  embedded_in :commentable, :polymorphic => true

  default_scope order_by(:created_at => :asc)

  validates_presence_of :content

  #FIXME: look into whether this is worth doing
  before_create :denormalize_username

  private

  def denormalize_username
    self.username = user.username
  end
end
