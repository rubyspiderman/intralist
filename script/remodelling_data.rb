#1
List.where(:_type => "Request").all.each do |request|
  req = Request.new(:name => request.name,
              :user_id => request.user_id)
  req["_id"] = request.id
  req["created_at"] = request.created_at
  req["updated_at"] = request.created_at
  req.save!
end

#2
List.collection.find({:_type => "Request"}).remove_all

#Clear out responses without requests.  Legacy shit
#3
#
#assumes all responses have same name

Request.asc(:created_at).each do |req|
  req.send(:create_list_group)
  req.reload
  lg = req.list_group
  lg["updated_at"] = req.created_at
  lg.save!
end

List.asc(:created_at).each do |list|
  list.send(:create_or_update_list_group)
  list.reload
  lg = list.list_group
  lg["updated_at"] = list.created_at #bc if they were promoted updated_at is botched
  lg.save!
end

User.all.each do |user|
  u.notifications.where(:created_at.gte => 1.hour.ago).destroy_all
end
