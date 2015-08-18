#TODO: Refactor this #shamelessHack. Use directive once angular ui supports custom triggers
setTimeout( ->
  $("input[name='name']").on('blur', ->
    length = $(this).val().length
    if ((length < 5) || (length > 200))
      $(this).tooltip(title: 'Name must be between 5 and 200 characters.', trigger: 'manual', placement: 'right')
      $(this).tooltip('show')
  )

  $("input[name='name']").on('focus', ->
    $(this).tooltip("destroy")
  )
, 3000)

#TODO: split out copying and responding code into a separate controller
intralist.controller 'NewListCtrl', ['$scope', 'List', 'autoCompletion', ($scope, List, autoCompletion) ->
  #Q: Do we need the query tokenizers?  E.g. If someone types, "New York", maybe we only want exact matches?
  #TODO: Return a count with each to filter by popularity
  if $scope.props.state == "copying"
    $scope.oldList = angular.copy($scope.list)
    $scope.list.clearDescriptions()
  else if $scope.props.state != "responding"
    $scope.list = List.newList()

  $scope.autoCompletion = autoCompletion

  $scope.showDescLink = -> $scope.descLink = true
  $scope.hideDescLink = -> $scope.descLink = false

  $scope.focusItemIndex = 54

  $scope.changeFocus = (itemIndex) -> 
    $scope.focusItemIndex = itemIndex

  #TODO:  Extract this somehow and make it clear that it's a dependency for the
  #new_list_item_controller. Might make sense to just make these lines a
  #service.
  $scope.active =
    item: null

  $scope.viewText =
    submitText: "PUBLISH"

  #Q: Is there a move conventional way to do this?  I'm not reaching into parent
  #here.
  $scope.$on "uploadInProgress", (event, value) ->
    $scope.uploadInProgress = value

  $scope.toggleDetail = ($index) ->
    $scope.activePosition = $index

  $scope.$on "toggleNewList", ->
    $scope.toggleNewList()

  $scope.toggleNewList = ->
    $scope.$emit "toggleNewCopy" #shouldn't happen everywhere
    $scope.creatingList = !$scope.creatingList

  #FIXME: $scope.validateName = ...

  $scope.cancel = ->
    if $scope.props.state == "responding"
      $scope.props.state = "viewingRequest"
    else if $scope.props?.state == "copying"
      $scope.prev()
      $scope.$emit "copyCancelled", $scope.oldList
    else
      $scope.toggleNewList()

  #TODO: Validation for a list with an image but no item name
  $scope.saveList = ->
    user = {username: $scope.current_user_name, profile: {facebook_image: $scope.current_user_image}}
    $scope.list.request_id = $scope.request.id if $scope.request
    #NOTE: $scope.oldList only defined for a copy
    list_group = List.createList($scope.list, $scope.oldList, user)

    if $scope.list.request_id
      $scope.$emit "responseCreated", list_group
    else if $scope.list.copy
      $scope.$emit "copyCreated", list_group
    else
      $scope.list_groups.unshift(list_group)

    $scope.list = List.newList()
    $scope.toggleNewList()
]
