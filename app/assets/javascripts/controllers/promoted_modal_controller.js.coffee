intralist.controller 'PromotedModalCtrl', ['$scope', '$modalInstance', 'list', ($scope, $modalInstance, list) ->
  $scope.list = list

  $scope.ok = ->
    $modalInstance.close()

  $scope.cancel = ->
    $modalInstance.dismiss('cancel')
]
