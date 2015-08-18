intralist.directive "iTagRotator", ['$timeout', ($timeout) ->
  restrict: 'AE'
  replace: true
  scope: 
    taglines: '='
  link: (scope, element, attr) ->
    
    scope.currentIndex = 0
    
    scope.next = ->
      if scope.currentIndex < scope.taglines.length - 1 then scope.currentIndex++ else (scope.currentIndex = 0)
    
    sliderFunc = ->
      timer = $timeout((->
        scope.next()
        timer = $timeout(sliderFunc, 3000)
        return
      ), 5000)
      return  
    
    scope.$watch 'currentIndex', ->
      scope.taglines.forEach (tagline) ->
        tagline.visible = false
        # make every image invisible
        return
      scope.taglines[scope.currentIndex].visible = true
      # make the current image visible
      return

    sliderFunc()
    
    scope.$on '$destroy', ->
      $timeout.cancel timer
      # when the scope is getting destroyed, cancel the timer
      return
 
  template: 
    "<p class='tagline' ng-repeat='tagline in taglines' ng-show='tagline.visible' ng-class='{showing: tagline.visible}'>{{tagline.text}}</h2>"
]

    