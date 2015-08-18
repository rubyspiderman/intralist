intralist.controller 'EditListCtrl', ['$scope', 'List', 'autoCompletion', ($scope, List, autoCompletion) ->

  $scope.showDescLink = ->
    $scope.descLink = true
  $scope.hideDescLink = ->
    $scope.descLink = false

  $scope.focusItemIndex = 54

  $scope.changeFocus = (itemIndex) -> 
    $scope.focusItemIndex = itemIndex

  $scope.autoCompletion = autoCompletion
  $scope.oldList = angular.copy($scope.list)

  $scope.active =
    item: null

  $scope.viewText =
    submitText: "UPDATE LIST"

  $scope.cancel = ->
    $scope.$emit "finishedEditing", $scope.oldList, $scope.props.state
    if $scope.props.state == "editing"
      $scope.props.state = "viewingConnectedList"
    else if $scope.props.state == "editingFreshCopy"
      $scope.props.state = "viewingFreshCopy"

  $scope.saveList = ->
    id = $scope.list.id || $scope.list.cid
    #if name changed, make new ListGroup
    $scope.list.$update({id: id})
    $scope.$emit "finishedEditing", $scope.list, $scope.props.state
]
