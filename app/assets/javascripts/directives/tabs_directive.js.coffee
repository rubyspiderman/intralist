intralist.directive("tabs", ->
  restrict: "E"
  transclude: true
  scope: {}
  controller: ['$scope', '$element', ($scope, $element) ->
    panes = $scope.panes = []
    $scope.select = (pane) ->
      angular.forEach panes, (pane) ->
        pane.selected = false
        return

      pane.selected = true
      return

    @addPane = (pane) ->
      $scope.select pane  if panes.length is 0
      panes.push pane
      return

    return
  ]
  template: "<div class=\"tabbable\">" + "<ul class=\"tabs\">" + "<li ng-repeat=\"pane in panes\" ng-class=\"{active:pane.selected}\">" + "<a ng-click=\"select(pane)\">{{pane.title}}</a>" + "</li>" + "</ul>" + "<div class=\"tab-content\" ng-transclude></div>" + "</div>"
  replace: true
).directive "pane", ->
  require: "^tabs"
  restrict: "E"
  transclude: true
  scope:
    title: "@"
  link: (scope, element, attrs, tabsCtrl) ->
    tabsCtrl.addPane scope
    return
  template: "<div class=\"tab-pane\" ng-class=\"{active: selected}\" ng-transclude>" + "</div>"
  replace: true
