intralist.factory 'Follower', ['$resource', ($resource) ->
  Follower = $resource("/api/users/:user_id/follows", {user_id: "@user_id", follower_id: "@follower_id"}, 
    delete: {method: "DELETE", url: "/api/users/:user_id/follows/:follower_id", params: {user_id: "@user_id", follower_id: "@follower_id"}})
]
