intralist.controller 'CarouselModalInstanceCtrl', ['$scope', '$modalInstance', 'items', 'listName', 'listId', 'slideTo', ($scope, $modalInstance, items, listName, listId, slideTo) ->
  $scope.listId = listId
  $scope.items = items
  $scope.listName = listName
  $scope.slideTo = slideTo

  items.forEach( (item) -> item.activated = false )
  items[slideTo].activated = true  if slideTo?

  $scope.ok = ->
    $modalInstance.close()

  $scope.cancel = ->
    $modalInstance.dismiss('cancel')
]
