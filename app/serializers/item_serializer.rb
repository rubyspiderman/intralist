class ItemSerializer < BaseSerializer
  attributes :id, :name, :description, :link, :image_url, :image_thumb_url, :image_small_url

  def image_thumb_url
    _image_url("thumb")
  end

  def image_small_url
    _image_url("small")
  end

  private

  def _image_url(size)
    if self.image_url
      url = self.image_url.split("/")
      #TODO: If we migrate all the items to point to cloudfront we can remove tihs line
      #TODO: revert
      url[2] = "d11klizz3i72ef.cloudfront.net" #if Rails.env.production?
      url[url.length - 1] = "#{size}_" + url[url.length - 1]
      url.join("/")
    end
  end

end
