intralist.controller "HomePageCtrl", ['$scope', '$routeParams', 'List', ($scope, $routeParams, List) ->
  $scope.props = {loading: true}
  $scope.lists = List.query({filter: "promoted"}, ->
    #FIXME: Something off with the CSS here where setting this to false makes
    #it not display
    # $scope.props.loading = false
  )
  $scope.page = 1
  
  $scope.taglines = [
    {text: "A new way to discover the information that matters to you."},
    {text: "Delivering definitive top-five lists on any topic."},
    {text: "Using real opinions to deliver you real results."},
    {text: "Turning the noise into clear, useful signals."},
    {text: "Powered by the genuine opinions of friends, brands and influencers"}
  ]
  
  $scope.loadMore = ->
    $scope.page += 1
    $scope.props.loading = true

    List.query({filter: "promoted", page: $scope.page}, (data)  ->
      $scope.lists = $scope.lists.concat data
      $scope.props.loading = false
    )
]
