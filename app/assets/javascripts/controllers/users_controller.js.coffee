intralist.controller "UsersCtrl", ['$scope', '$routeParams', '$upload', 'User', 'Follower', 'List', 'Request', 'Profile', 'Bookmark', 'breadcrumb', 'ListGroup', ($scope, $routeParams, $upload, User, Follower, List, Request, Profile, Bookmark, breadcrumb, ListGroup) ->
  $scope.breadcrumb = breadcrumb
  $scope.showList = true
  $scope.editState = false
  $scope.showProgressBar = false
  $scope.uploadProgress = 0
  $scope.editDescription = true
  $scope.props = {loading: true, followsUser: false}

  $scope.user = User.get({id: $routeParams.id}, ->
    $scope.list_groups = ListGroup.query({filter: "user", user_id: $scope.user.id}, (list_groups) ->
      ListGroup.castLists(list_groups)
      list_groups.forEach (list_group) ->
        list_group.bubbleUsersList($scope.user)
      $scope.props.loading = false
    )

    followers = $scope.user.followers.map (user) -> user.username
    $scope.props.followsUser = followers.indexOf($scope.current_user_name) != -1
  )

  $scope.facebookLarge = ->
    if $scope.user.profile.image_display == 'facebook'
      if /\?type=square/.test($scope.user.profile.avatar)
        return $scope.user.profile.avatar.replace(/\?type=square/, '?type=large')
      else
        return $scope.user.profile.avatar + '?type=large'
  $scope.showRequests = ->
    $scope.requests = Request.query({filter: "by_me"})

  $scope.showBookmarks = ->
    $scope.bookmarks = Bookmark.query({user_id: $routeParams.id})
    # need to inject Bookmark.  Not doing that now because there's an issue

  $scope.addFollower = ->
    newFollower = new Follower({user_id: $scope.current_user_name, follower_id: $routeParams.id})
    newFollower.$save() # Add success / failure 
    $scope.user.followers.push({username: $scope.current_user_name, image: $scope.current_user_image})
    $scope.user.follower_count += 1
    $scope.props.followsUser = true

  $scope.removeFollower = ->
    removeFollower = new Follower({user_id: $scope.current_user_name, follower_id: $routeParams.id})
    removeFollower.$delete()
    $scope.user.follower_count -= 1
    remove_follower($scope.user.followers, $scope.current_user_name)
    $scope.props.followsUser = false
    # TODO: Find the user in user.followers to delete
    # QUESTION: shouldn't angular be maintaining all this through bindings?  Getting from User, updating through Follows, so it's not right yet.
    # Maybe the updates need to take place on the user model.  Update followers through user.

  $scope.myProfile = ->
    $scope.current_user_name == $routeParams.id

  remove_follower = (array, username) ->
    u = array.filter((user) -> user.username == username)[0]
    i = array.indexOf(u)
    array.splice(i, 1)

  $scope.setFollower = ->
    if $scope.props.followsUser
      $scope.removeFollower()
    else
      $scope.addFollower()

  $scope.editProfile = ->
    $scope.editState = true
    $scope.originalDescription = $scope.user.profile.description
    $scope.originalLocation = $scope.user.profile.location
    $scope.originalLink = $scope.user.profile.link

  $scope.updateProfile = ->
    Profile.update
      user_id: $scope.user.id
    , $scope.user
    $scope.editState = false
    # TODO: if there's a problem, show an error message
    #
  $scope.cancelEditProfile = ->
    $scope.showProfilePicPop = false
    $scope.user.profile.description = $scope.originalDescription 
    $scope.user.profile.location = $scope.originalLocation
    $scope.user.profile.link = $scope.originalLink

  $scope.showProgress = (percent) ->
    if percent && percent < 100
      true
    else
      false

  $scope.onFileSelect = ($files) ->
    $scope.showProgressBar = true
    i = 0
    while i < $files.length
     file = $files[i]
     i++
     $scope.upload = $upload.upload(
      # TODO: this should be dried up to use the Profile factory
       method: "PUT"
       url: "/api/users/" + $scope.user.id + "/profile"
       data:
         "profile[image]": file
         id: $scope.user.id
     ).progress((evt) ->
       # console.log "percent: " + parseInt(100.0 * evt.loaded / evt.total)
       $scope.uploadProgress = parseInt(100.0 * evt.loaded / evt.total)
       $scope.showProfilePicPop = false
     ).success((data, status, headers, config) ->
       # file is uploaded successfully
       $scope.setAvatar("upload")
       $scope.showProgressBar = false
       return
     )

  $scope.setAvatar = (provider) ->
    $scope.showProfilePicPop = false
    $scope.user.profile.image_display = provider
    # TODO: this should probably use a promise
    $scope.user = Profile.update
      user_id: $scope.user.id
     , $scope.user

  $scope.page = 1
  $scope.loadMore = ->
    $scope.page += 1
    ListGroup.query({filter: "user", user_id: $scope.user.id, page: $scope.page}, (list_groups) ->
      ListGroup.castLists(list_groups)
      list_groups.forEach (list_group) ->
        list_group.bubbleUsersList($scope.user)
      $scope.list_groups = $scope.list_groups.concat list_groups
    )
]
