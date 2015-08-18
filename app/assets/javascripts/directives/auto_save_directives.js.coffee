intralist.directive 'autoSave', [
  '$timeout'
  'localStorageService'
  ($timeout, localStorageService) ->
    {
    restrict: 'A'
    link: ($scope, $element, $attrs) ->
      name = $attrs.autoSaveName
      formElement = $element[0]
      interval = 0

      window.onbeforeunload = ->
        #newData = $element.serializeArray()
        #tags = {name:'tags', values:$scope.list.tags}

        #newData.push(tags)
        #localStorageService.set name, newData
        if $scope.draft == true
        	localStorageService.set name, JSON.stringify($scope.list)
        else
          localStorageService.remove name
        return

      $scope.$resetAutoSave = ->
        #localStorageService.remove name
        localStorageService.remove name
        $($element).find('input[type=text],input[type=file], textarea').val ''
        $scope.draft = false
#        $scope.list.tags = []
        for item in $scope.list.items
          item.description = ''
          item.name = ''
          item.image_url = ''
          item.image_thumb_url = ''
        return

      $timeout (->
        list = localStorageService.get(name)
        if list
          $scope.list = list
          $scope.draft = true
#        autoSaved = localStorageService.get(name)
#        newData = $element.serializeArray()
#        if autoSaved and autoSaved.length
#          autoSaved.map (elem) ->
#            if elem.name == 'tags'
#              $scope.list.tags = elem.values
#            else
#              $(formElement[elem.name]).val(elem.value).trigger 'input'
        return
      ), interval

      if !name
        throw new Error('auto-save-name attribute should be specified.')
      return

    }
]
