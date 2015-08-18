intralist.controller 'RequestListGroupCtrl', ['$scope', 'List', ($scope, List) ->
  #NOTE: We reference the request so the responses carousel can be preserved as
  #$scope.list changes around it
  $scope.request = $scope.list_group.request
  #XXX: The responses and request share a template, so we call request a list
  #to start
  $scope.list = $scope.list_group.request

  $scope.props =
    state: "viewingRequest"
    currentResponseIndex: 0

  $scope.respond = ->
    $scope.list = List.newList({name: $scope.list.name})
    $scope.list.user =
      {username: $scope.current_user_name, profile: {facebook_image: $scope.current_user_image}}
    $scope.list.created_at_in_words = "moments ago"
    $scope.props.state = "responding"

  $scope.viewResponses = ->
    $scope.props.state = "viewingResponses"
    $scope.props.currentResponseIndex = 0
    $scope.list = $scope.list_group.lists[0]

  $scope.backToRequest = ->
    $scope.props.state = "viewingRequest"
    $scope.list = $scope.request

  $scope.$on 'responseCreated', (event, response) ->
    $scope.props.state = "viewingRequest"
    $scope.list_group.lists.unshift(response)
    $scope.viewResponses()

  $scope.$on "slideChanged", (event, index) ->
    if index == -1
      return
    else
      $scope.props.currentResponseIndex = index
      $scope.list = $scope.list_group.lists[index]
      return
]
