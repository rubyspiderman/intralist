intralist.directive "largeProfileImage", ->
  restrict: 'E'
  link: (scope, element, attrs) ->
    scope.myUrl = user.profile.image_display
  template: "<b>{{myUrl}}</b>"
  
 
