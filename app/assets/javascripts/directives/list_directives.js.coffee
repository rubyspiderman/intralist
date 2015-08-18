
intralist.directive "iShare", [
  "$timeout"
  ($timeout) ->
    return (
      restrict: "E"
      transclude: true
      replace: true
      scope:
        title: '@iShareTitle'
        slug: '@iShareSlug'
        path: '@iSharePath'
        coverImage: '@iShareCoverImage'
      template: "<div class=\"addthis_toolbox addthis_default_style addthis_20x20_style\">" + "<a class=\"addthis_button_facebook\"></a> " + "<a class=\"addthis_button_twitter\"></a>" + "<a class=\"addthis_button_google_plusone_share\"></a>" + "<a class=\"addthis_button_email\"></a>" + "</div></div>"
      link: ($scope, element, attrs) ->
        shareUrl = "http://www.intralist.com/" + $scope.path + "/" + $scope.slug
        twitterTemplate = ->
          if $scope.path == 'requests'
            tweet = "Can you complete this request? '" + $scope.title + "' on Intralist " + shareUrl
          else
            tweet = "Check out '" + $scope.title + "' on Intralist " + shareUrl
          return tweet
        facebookTemplate = ->
          if $scope.path == 'requests'
            message = "Can you complete this request? '" + $scope.title + "' on Intralist " + shareUrl
          else
            message = "Check out '" + $scope.title + "' on Intralist " + shareUrl
          return message
        $timeout ->
          addthis.init()
          addthis_ui_config =
            data_track_addressbar: true
          addthis_share_config =
            url: shareUrl
            title: $scope.title
            templates:
              twitter: twitterTemplate()
              facebook: facebookTemplate()

          addthis.toolbox element.get(), addthis_ui_config, addthis_share_config
          return

        return
    )
]

intralist.directive 'iToggleList', ->
  restrict: 'A'
  link: ($scope, element, attrs) ->
    element.click (e) ->
      tags = ["INPUT", "A", "FORM", "SPAN", "BUTTON", "IMG", "TEXTAREA"]
      klass = e.target.className
      if (!klass.match(/tags|list-image|comment-text|tag-list/)) && (tags.indexOf(e.target.tagName) == -1)
        $scope.props.expanded = !$scope.props.expanded
        $scope.$apply()
      else if klass.match(/tag-list/)
        $(e.target).closest(".tags").find("input.tag-input").focus()

intralist.directive 'iAddDescription', ['$timeout', ($timeout) ->
  restrict: 'A'
  scope: 
    item: '=ngModel'
    focusItemIndex: '=focusItemIndex'
    itemIndex: '=itemIndex'
  template:
    '<div class="clear"></div>' +
    '<a class="description-textarea-control" ng-click="toggleDesc()" ng-show="focusItemIndex == itemIndex" ng-hide="focusItemIndex != itemIndex || showDesc == true">+ add description</a>' +
    '<textarea rows="2" class="form-control description-textarea" ng-show="showDesc && focusItemIndex == itemIndex || inPlaceEdit == true" ng-model="item.description" name="desc_{{itemIndex}}" value="{{item.description}}"></textarea>' +
    '<span ng-show="focusItemIndex != itemIndex" ng-click="inPlaceEdit()" ng-hide="inPlaceEdit == true" class="item-description">{{item.description}}</span>'
  link: (scope, element, attrs) ->
    scope.showDesc = false
    scope.inPlaceEdit = false
    textArea = element.find('textarea')
    scope.$watch 'focusItemIndex', (newValue, oldValue) ->
      $timeout ->
        if newValue != oldValue
          scope.showDesc = false
    scope.toggleDesc = ->
      scope.showDesc = !scope.showDesc
      if scope.showDesc == true
        $timeout ->
          textArea.focus()
    scope.inPlaceEdit = ->
      scope.inPlaceEdit = true
]

intralist.directive "iEnter", ->
  ($scope, element, attrs) ->
    element.bind "keypress", (event) ->
      if event.which is 13
        $scope.$apply ->
          $scope.$eval attrs.iEnter, {event: event}
          event.preventDefault();

intralist.directive "iValidateUniqueness", ->
  restrict: 'A'
  require: 'ngModel'
  link: ($scope, element, attrs, formController) ->
    formController.$parsers.unshift (name) ->
      name = element.val()
      if name.length
        names = $scope.list.items.filter (item) -> item.name == name
        if names.length
          element.tooltip(title: 'Item name must be unique.', trigger: 'manual', placement: 'right')
          element.tooltip('show')
          formController.$setValidity("itemUniqueness", false)
        else
          element.tooltip('destroy')
          formController.$setValidity("itemUniqueness", true)
          return name
      else
        formController.$setValidity("itemUniqueness", true)
        return name

# Use this if we're doing client side image previews for link images before
# uploading
# intralist.directive 'fallbackSrc', ->
  # link: (scope, iElement, iAttrs) ->
    # iElement.bind('error', ->
      # angular.element(this).attr("src", iAttrs.fallbackSrc);
    # )
