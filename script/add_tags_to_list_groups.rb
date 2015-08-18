invalid = []
ListGroup.each do |group|
  group.lists.each do |list|
    group.add_tags(list.tags.map(&:name))
  end
  begin
    group.save!
  rescue
    invalid << group.id
  end
end
