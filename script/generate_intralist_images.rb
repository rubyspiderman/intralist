ids = []
Intralist.all.each_with_index do |intralist, i|
  items = intralist.lists.asc(:created_at).map(&:items).flatten
  intralist.intralist_items.each do |intralist_item|
    item = items.detect { |item| (item.name == intralist_item.name) && item.image_url }
    intralist_item.image_url = item.image_url if item
    item = items.detect { |item| (item.name == intralist_item.name) && item.link }
    intralist_item.link = item.link if item
  end
  intralist.save!
  ids << intralist.id
end
