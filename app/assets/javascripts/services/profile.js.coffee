intralist.factory 'Profile', ['$resource', ($resource) ->
  Profile = $resource('/api/users/:user_id/profile', {user_id: "@user_id"}, update: {method: "PUT"})
]
