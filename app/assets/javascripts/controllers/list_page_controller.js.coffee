intralist.controller "ListPageCtrl", ["$scope", "ListGroup", "User", "list_group", ($scope, ListGroup, User, list_group) ->
  #Q: Is there a better way to do this?  Such as passing in parameters to the
  #controller?  Could get confusing when properties are being inherited from the
  #parent scope, and it's not completly apparent in the code at which point
  #they're defined.
  $scope.viewingIndividual = true

  $scope.list_group = list_group
  ListGroup.castLists([list_group])

  slug = window.location.pathname.replace("/lists/", "")
  list_group.bubbleListBySlug(slug)

  $scope.list = $scope.list_group.lists[0]
  $scope.user = User.get({id: list_group.lists[0].user.id})
]
