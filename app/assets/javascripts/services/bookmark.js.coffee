intralist.factory 'Bookmark', ['$resource', ($resource) ->
  Bookmark = $resource("/api/users/:user_id/bookmarks", {user_id: "@user_id"}, update: {method: "PUT"})  
]
