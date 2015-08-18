intralist.controller "RequestPageCtrl", ["$scope", "$routeParams", "ListGroup", "request_list_group", ($scope, $routeParams, ListGroup, request_list_group) ->
  #Q: Is there a better way to do this?  Such as passing in parameters to the
  #controller?  Could get confusing when properties are being inherited from the
  #parent scope, and it's not completly apparent in the code at which point
  #they're defined.
  $scope.breadcrumb = $routeParams.id

  $scope.viewingIndividual = true
  ListGroup.castLists([request_list_group])
  $scope.list_group = request_list_group

  #this should really be something like current item, or "activeSlide"
  $scope.list = $scope.request

  $scope.dashStripper = (text) ->
    return text.replace(/-/g, " ")

]
