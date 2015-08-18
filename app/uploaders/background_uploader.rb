class BackgroundUploader < ImageUploader
  process :resize_to_limit => [1600, 1200]
  version :thumb do
    process :resize_to_fill => [250,250]
  end

end
