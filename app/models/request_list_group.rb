class RequestListGroup < ListGroup
  belongs_to :request

  def first_list
    #XXX: .intralist is delegated to this method so it can't return nil
    lists.empty? ? List.new : lists.first
  end

  def self.create_list_group(request)
    RequestListGroup.create(:request_id => request.id, :name => request.name)
  end

  #Responses don't create new feed items, they're only added to existing ones
  def self.add_to_list_group(response)
    list_group = RequestListGroup.where(:name => response.name).first
    list_group.list_ids << response.id
    list_group.save!
  end
end
