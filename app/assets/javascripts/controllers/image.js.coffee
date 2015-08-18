# app = angular.module("Intralist", [])
# 
# app.config ($httpProvider) ->
# 
# 
# @imageCtrl = ($scope, $http) ->
#   $http.defaults.headers.common = "Access-Control-Request-Headers": "accept, origin, authorization" #you probably don't need this line.  This lets me connect to my server on a different domain
#   $http.defaults.headers.common["Authorization"] = "Basic " + ":kj72Nq2+oCegC1ZVPIm4IIKB4JER1dvcilLz4SCYjnc"
# 
#   # this callback will be called asynchronously
#   # when the response is available
#   $http(
#     method: "GET"
#     url: "https://api.datamarket.azure.com/Bing/Search/v1/Composite",
#     Query: "%27farm%27", 
#     Sources: "%27image%27"
#   ).success((data, status, headers, config) ->
#     alert data
#   ).error (data, status, headers, config) ->
#     alert data


# @imageCtrl = ($scope, $http, Base64) ->
#   delete $http.defaults.headers.common['X-Requested-With']
#   $http.defaults.headers.common = "Access-Control-Request-Headers": "accept, origin, authorization"
#   $http.defaults.headers.common["Authorization"] = "Basic " + "" + ":" + "kj72Nq2+oCegC1ZVPIm4IIKB4JER1dvcilLz4SCYjnc"
#   $http({method: 'GET', url: 'https://api.datamarket.azure.com/Bing/Search/v1/Composite'},
#   {Query: "%27farm%27", Sources: "%27image%27"})
#     .success (data, status, headers, config) ->
#       alert "yes"
#     .error (data, status, headers, config) ->
#       alert "no"
