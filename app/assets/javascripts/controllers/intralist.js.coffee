#FIXME: This doesn't seem to be fully implemented
intralist.controller 'intralistCtrl', ['$scope', '$resource', ($scope, $resource) ->
  Intralist = $resource("/intralists/:id", {id: "@id"}, {update: {method: "PUT"}})
  $scope.intralists = Intralist.query()
]
