class Response < List
  belongs_to :request

  private

  def create_or_update_list_group
    RequestListGroup.add_to_list_group(self)
    super
  end
end
