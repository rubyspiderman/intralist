intralist.factory 'Comment', ['$resource', ($resource) ->
  #NOTE: This can't accomodate either a list ID or an InstralistID so we just
  #past list_id
  #NOTE: DELETE does not support a request body
  Comment = $resource("/api/lists/:list_id/comments/:id", {id: "@id", list_id: "@list_id"}, update: {method: "PUT"}, destroy: {method: "POST"})

  #TODO: use built in angular hash function
  Comment.generateClientID = -> return Math.random().toString(36).substring(9)

  Comment
]
