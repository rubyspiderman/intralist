intralist.directive("iScroll", ['$window', ($window) ->
  (scope, element, attrs) ->
    angular.element($window).unbind "scroll"
    angular.element($window).bind "scroll", ->
      if $(window).scrollTop() == $(document).height() - $(window).height()
        scope.$apply attrs.iScroll
])

intralist.directive("tip", ->
  restrict: 'E'
  link: ($scope, element, attrs) ->
    $scope.alts = [
      "Create your first list, click 'create list'",
      "Make your own version, copy another user's list",
      "Get into the game, click 'Create List' to make a list",
      "Need some help with a topic?  Request a list",
      "Intralists aggregagte results from lists with more then one copy"
    ]
    $scope.srcs = [
      "create_tip.jpg",
      "copy_list_tip.jpg",
      "create_tip_two.jpg",
      "request_tip.jpg",
      "intralist_tip.jpg"
    ]
    $scope.i = parseInt(Math.random() * $scope.srcs.length)
  template: '<div><img alt="{{alts[i]}}" ng-src ="../assets/tips/{{srcs[i]}}"/></div>'
)
