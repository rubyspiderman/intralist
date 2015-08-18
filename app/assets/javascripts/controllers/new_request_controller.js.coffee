intralist.controller 'NewRequestCtrl', ['$scope', 'Request', 'ListGroup', ($scope, Request, ListGroup) ->
  $scope.request = Request.newRequest()
  
  $scope.focusItemIndex = 54
  
  $scope.$on "toggleNewRequest", ->
    $scope.toggleNewRequest()

  $scope.toggleNewRequest = ->
    $scope.creatingRequest = !$scope.creatingRequest

  $scope.createRequest = ->
    list_group = ListGroup.newRequestListGroup($scope.request)
    $scope.list_groups.unshift(list_group)
    $scope.request.$save()
    $scope.toggleNewRequest()
]
