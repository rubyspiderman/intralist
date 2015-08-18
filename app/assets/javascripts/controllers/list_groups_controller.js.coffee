intralist.controller 'ListGroupsCtrl', ['$scope', 'List', '$routeParams', '$modal', '$location', 'ListGroup', ($scope, List, $routeParams, $modal, $location, ListGroup) ->
  $scope.props =
    loading: true
    allListsFetched: false

  $scope.$on('$routeChangeSuccess', ->
    if $routeParams.tag
      $scope.list_groups = ListGroup.query {filter: "tag", tag: $routeParams.tag}, (data) ->
        ListGroup.castLists(data)
        $scope.props.loading = false
      $scope.breadcrumb = "TAG : " + $routeParams.tag
    else
      $routeParams.filter = $location.path().slice(1)
      $scope.list_groups = ListGroup.query {filter: $routeParams.filter}, (data) ->
        ListGroup.castLists(data)
        $scope.props.loading = false
      $scope.breadcrumb = $routeParams.filter
  )

  #TODO: create a current_user on user service to avoid using the global scope
  $scope.current_user_name = window.current_user_name
  $scope.current_user_image = window.current_user_image
  $scope.currentItemId = 0

  $scope.page = 1

  $scope.dashStripper = (text) ->
    return text.replace(/-/g, " ")

  $scope.loadMore = ->
    return if $scope.props.allListsFetched

    $scope.props.loading = true

    $scope.page += 1
    if $routeParams.tag
      options = {filter: "tag", tag: $routeParams.tag, page: $scope.page}
    else
      options = {filter: $routeParams.filter, page: $scope.page}
    ListGroup.query(options, (response) ->
      if response.length
        list_groups = response.map( (list_group) -> new List(list_group) )
        $scope.list_groups = $scope.list_groups.concat list_groups
        ListGroup.castLists(list_groups)
        $scope.props.loading = false
      else
        $scope.props.allListsFetched = true
    )

]
