require 'file_size_validator'

class Profile
  include Mongoid::Document
  include Mongoid::Timestamps
  field :facebook_image
  field :twitter_image
  field :image_display
  field :description
  field :location
  field :background_color
  field :background_repeat
  field :theme_image
  field :link

  embedded_in :user
  mount_uploader :image, AvatarUploader
  mount_uploader :background_image, BackgroundUploader

  validates_integrity_of :image, if: :should_validate_file
  validates_integrity_of :background_image, if: :should_validate_file
  validates_integrity_of :banner, if: :should_validate_file
  validate :file_size, if: :should_validate_file
  attr_accessible :image, :image_cache, :background_image, :background_image_cache, :theme_image, :description, :first_name, :last_name, :location, :link, :gender, :background_color, :image_display, :facebook_image, :twitter_image, :background_repeat, :remove_background_image
  
  after_update :update_avatar
   
  def avatar
    img = '/assets/annonymous_user.jpg'
    if image_display.nil? || image_display.blank? || image_display.eql?('upload')      
      img = image.nil? ? '/assets/annonymous_user.jpg' : image.url(:thumb)
    elsif image_display.eql?('facebook')
      img = facebook_image
    elsif image_display.eql?('twitter')
      img = twitter_image
    end
    img = '/assets/annonymous_user.jpg' if img.nil?
    img
  end

  def update_avatar
    Resque.enqueue(AvatarUpdator, self.user.id)
    logger.info "I should have enqueued this job"
  end

  protected

  def should_validate_file
    self.changes[:file] && self.file.present?
  end

  def file_size
    if self.file.size.to_f/(1000*1000) > 0.5.megabytes.to_f
      errors.add(:file, "You cannot upload a file greater than 200 MB")
    end
  end
  
end
