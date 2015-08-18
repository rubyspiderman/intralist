intralist.controller 'ModalInstanceCtrl', ['$scope', '$modalInstance', ($scope, $modalInstance) ->
  $scope.ok = ->
    $modalInstance.close()

  $scope.cancel = ->
    $modalInstance.dismiss('cancel')
]
