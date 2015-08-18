module SearchHelper
  def list_profile_image(list)
    _list = List.find(list._id)
    image_urls = _list.items.collect(&:image_url).compact
    image_urls.empty? ? image_urls.shuffle.last : nil
  end

  def intra_list_profile_image(intralist)
    _intralist = Intralist.find(intralist._id)
    lists = _intralist.lists
    image_urls = []

    lists.each do |list|
      image_urls << list_profile_image(list)
    end

    image_urls.empty? ? nil : image_urls.compact.shuffle.last
  end
end
