intralist.controller 'ListGroupCtrl', ['$scope', '$timeout', '$modal', 'List', ($scope, $timeout, $modal, List) ->

  # Useful for debugging
  # $scope.$watch "list", (newVal, oldVal) ->
    # console.log "..."
    # console.log newVal.slug
    # console.log("new list:")
    # console.log(newVal)
    # console.log("old list:")
    # console.log(oldVal)

  $scope.props =
    state: "viewingConnectedList",
    expanded: $scope.viewingIndividual || false,
    copyCreated: false

  $scope.currentListIndex = 0
  $scope.mainList = $scope.list_group.lists[0]
  $scope.list = $scope.mainList

  $scope.$on "slideChanged", (event, index) ->
    #XXX: Carousel starts at -1 for some reason
    if index == -1
      return
    else if $scope.props.state == "viewingConnectedList"
      #ConnectedList Carousel
      $scope.currentListIndex = index
      $scope.list = $scope.list_group.lists[index]
    else
      #Intralist Slide
      if index == 2
        $scope.list = $scope.list_group.intralist
      #Copy Slide
      else if index == 1
        if $scope.freshCopy
          $scope.list = $scope.freshCopy
        else
          $scope.copiedList = $scope.list
          $scope.list = angular.copy($scope.copiedList)
          $scope.list.id = null
          $scope.list.copy = true
          $scope.list.created_at = "Moments ago"
          $scope.list.parent_list_id = $scope.copiedList.id
          $scope.list.user = {"username": $scope.current_user_name}
      #ConnectedList Carousel Slide
      else if index == 0
        #NOTE: this scope has to change after the transition else the carousel will
        #disappear immediately
        $scope.props.state = "viewingConnectedList"
        $scope.list = $scope.mainList

  $scope.$on "copyCancelled", (event, list) ->
    #XXX: List is still changed after this is in the slideChanged callback
    $scope.mainList = $scope.list = list

  $scope.$on "copyCreated", (event, list) ->
    $scope.freshCopy = list
    $scope.list = $scope.freshCopy
    $scope.props.copyCreated = true
    $scope.props.state = "viewingFreshCopy"
    $scope.props.expanded = true

  $scope.$on "finishedEditing", (event, list, updatedFrom) ->
    #TODO: Is there a cleaner way to do this?  Feels a bit weird
    if updatedFrom == "editing"
      $scope.mainList = $scope.list = list
      $scope.props.state = "viewingConnectedList"
    else if updatedFrom == "editingFreshCopy"
      $scope.freshCopy = $scope.list = list
      $scope.props.state = "viewingFreshCopy"

  $scope.newListCopy = ->
    $scope.props.state = "copying"
    $scope.$broadcast("next")

  $scope.viewMain = (direction) ->
    $scope.props.state = "viewingConnectedList"
    $scope.$broadcast(direction)
    $scope.$broadcast('resetInner')

  $scope.backToCopy = ->
    $scope.props.state = "viewingFreshCopy"
    $scope.$broadcast("next")

  $scope.prevConnList = ->
    $scope.$broadcast("prevConnectedList")

  $scope.nextConnList = ->
    $scope.$broadcast("nextConnectedList")

  $scope.prev = ->
    $scope.$broadcast("prev")

  $scope.next = ->
    $scope.$broadcast("next")

  $scope.toggleFullText =->
    $scope.showFullText = !$scope.showFullText

  $scope.viewIntralist = ->
    $scope.props.expanded = true
    $scope.props.state = "viewingIntralist"
    $scope.$broadcast("prev")

  $scope.openCarousel = (slideTo) ->
    modalInstance = $modal.open
      templateUrl: "partials/carousel_modal.html"
      controller: "CarouselModalInstanceCtrl"
      resolve:
        items: ->
          $scope.list.items
        listName: ->
          $scope.list.name
        listId: ->
          $scope.list.id
        slideTo: ->
          slideTo

  $scope.openPromote = ->
    #  the problem here is that $scope.list can be more then one list.
    # TODO: when updated all the data for the list in the view is lost
    promotedListModal = $modal.open
      templateUrl: "partials/promote_list_modal.html"
      controller: "PromotedModalCtrl"
      resolve: 
        list: ->
          $scope.mainList
    promotedListModal.result.then (selectedItem) ->
      $scope.list.promoted = true
      $scope.mainList.$update({id: $scope.mainList.id})

  $scope.openUnpromote = ->
    #  the problem here is that $scope.list can be more then one list.
    unpromotedListModal = $modal.open
      templateUrl: "partials/unpromote_list_modal.html"
      controller: "ModalInstanceCtrl"
    unpromotedListModal.result.then (selectedItem) ->
      $scope.list.promoted = false
      $scope.list.carousel = false
      $scope.mainList.$update({id: $scope.mainList.id})

  $scope.editList = ->
    $scope.props.state = 'editing'
    $scope.props.expanded = true

  $scope.setItemId = (item) -> $scope.currentItemId = item
  $scope.clearItemId = -> $scope.currentItemId = 0

  $scope.confirmListDelete = ->
    console.log("deletion")
    list = @list
    list_group = @list_group

    deleteListModal = $modal.open
      templateUrl: "partials/confirm_delete_modal.html"
      controller: "ModalInstanceCtrl"

    deleteListModal.result.then (selectedItem) ->
      #TODO: refactor
      #lists feed
      if $scope.list_groups
        unless list.id
          list.id = list.cid
          i = $scope.list_groups.indexOf(list_group)
          $scope.list_groups.splice(i, 1)
          list = new List(list)
        else
          i = $scope.list_groups.indexOf(list_group)
          $scope.list_groups.splice(i, 1)
      #individual lists page
      else
        window.location = "recent"

      list.$delete()
      #TODO: Just remove the list from the list group

]
