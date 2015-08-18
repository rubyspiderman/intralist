intralist.factory "Accommodation", ["$resource", "$timeout", ($resource, $timeout) ->
  hotelName: (scope) ->
    $timeout (->
      scope.hotel = "Palace of tits and ass"
      return
    ), 3000
    "---"
  roomNumber: (scope) ->
    $timeout (->
      scope.roomno = "666"
      return
    ), 3000
    "---"
  
]
