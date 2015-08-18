class IntralistItem
  include Mongoid::Document
  field :name
  field :description
  field :contributors, type: Array, :default => []
  # Perhaps we can set the default value to [] and then use << ?
  field :count, type: Integer, :default => 1
  field :image_url
  field :link

  embedded_in :intralist, :inverse_of => :intralist_items

  scope :default, -> { where(:count.gt => 1).order_by(:count => :desc).limit(5) }

end
