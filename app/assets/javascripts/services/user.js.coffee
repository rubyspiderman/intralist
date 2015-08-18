intralist.factory 'User', ['$resource', ($resource) ->
  User = $resource("/api/users/:id", {id: "@id"}, update: {method: "PUT"})  
]
