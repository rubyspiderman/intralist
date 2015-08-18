class ItemUploader < ImageUploader
  process :resize_to_limit => [800, 800]

  version :thumb do
    process :resize_to_limit => [250, 250]
  end

  version :small do
    process :resize_to_limit => [325, 325]
  end

  def store_dir
    #NOTE: this is not thread safe
    @@id ||= Digest::MD5.new.hexdigest(original_filename + Time.now.to_s)
    "uploads/items/#{@@id}"
  end
end
