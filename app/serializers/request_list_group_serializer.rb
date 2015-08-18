class RequestListGroupSerializer < ListGroupSerializer
  has_one :request #only ones with resource-tye :request
end
