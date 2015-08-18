intralist.controller "NameCtrl", ['$scope', '$http', ($scope, $http) ->
  $scope.names = ["Best List Ever", "Best Movies In The World"]
  $scope.fetchNames = (value) ->
    $http.get("/search.json", {
      params:
        q: value
        f: "list"
    }).then (response) ->
      names = response.data.results.map (list) -> list.title
      names.filter (name) -> name.indexOf(value) != -1

]
