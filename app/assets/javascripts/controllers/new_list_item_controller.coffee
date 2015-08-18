intralist.controller 'NewListItemCtrl', ['$scope', 'List', '$upload', ($scope, List, $upload) ->

  $scope.props =
    showLinkControls: false
    showPhotoControls: false
    imageUploaded: false
    uploadInProgress: false
    hovered: false

  #TODO: Move these into a service so a function doesn't get defined for every
  #item
  $scope.uploadByImageUrl = (event) ->
    $scope.item.image_url = event.originalEvent.clipboardData.getData('text/plain')
    $scope.$emit("uploadInProgress", true)
    $scope.props.uploadInProgress = true

    $scope.active.item = @item
    $upload.upload(
      method: "POST"
      url: "/api/image_uploads"
      data:
        image_url: @item.image_url
        type: "item"
    ).success(@handleUploadSuccess).error(@handleError)

  $scope.uploadImage = (files) ->
    file = files[0]
    $scope.$emit("uploadInProgress", true)
    $scope.props.uploadInProgress = true

    $upload.upload(
      method: "POST"
      url: "/api/image_uploads"
      data:
        image: file
        type: "item"
    ).success(@handleUploadSuccess).error(@handleError)

  $scope.handleUploadSuccess = (data, status, headers, config) ->
    $scope.item.image_url = data.image_url
    $scope.item.image_thumb_url = data.image_thumb_url
    $scope.$emit("uploadInProgress", false)
    $scope.props.uploadInProgress = false
    $scope.props.imageUploaded = true

  $scope.handleError = ->
    $scope.props.uploadInProgress = false
    $scope.clearImage()
    alert("An error occurred while uploading your image.")

  $scope.clearImage = ->
    $scope.item.image_url = ""
    $scope.props.imageUploaded = false
    $scope.props.showPhoto = true

  $scope.hovering = (value) ->
    return if $scope.list.items.length == 1
    $scope.props.hovered = value
]
