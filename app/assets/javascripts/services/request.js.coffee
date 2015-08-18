intralist.factory 'Request', ['$resource', ($resource) ->
  Request = $resource("/api/requests/:id", {id: "@id", filter: "@filter"}, update: {method: "PUT"})

  Request.newRequest = ->
    request = new Request
    request.resource_type = "Request"
    request

  Request
]
