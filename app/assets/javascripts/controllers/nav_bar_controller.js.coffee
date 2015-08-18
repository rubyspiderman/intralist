intralist.controller 'NavBarCtrl', ['$scope', '$rootScope', '$location', ($scope, $rootScope, $location) ->
  $scope.toggleNewList = ->
    if $location.path() != "/recent"
      $location.path("/recent")
      $rootScope.creatingList = true
    $rootScope.$broadcast("toggleNewList")

  $scope.toggleNewRequest = ->
    if $location.path() != "/recent"
      $location.path("/recent")
      $rootScope.creatingRequest = true
    $rootScope.$broadcast("toggleNewRequest")
]
