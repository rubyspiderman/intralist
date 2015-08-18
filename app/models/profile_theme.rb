class ProfileTheme
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name, type: String
  field :background_repeat, type: String

  attr_accessible :background_image, :name, :background_repeat
  mount_uploader :background_image, BackgroundUploader
end
