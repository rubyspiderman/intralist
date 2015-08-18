class ImageUploader < CarrierWave::Uploader::Base
  include CarrierWave::RMagick

  storage :fog
  #NOTE: Uncomment the next line if you want to store photos on your own disk
  #while developing locally.
  # storage :file

  def extension_white_list
    %w(jpg jpeg gif png)
  end

  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end
end
