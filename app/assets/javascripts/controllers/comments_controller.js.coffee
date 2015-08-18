intralist.controller 'CommentsCtrl', ['$scope', '$resource', 'Comment', '$modal', '$http', '$q', ($scope, $resource, Comment, $modal, $http, $q) ->
  #NOTE: Alot of these methods could probably be pushed into the Comment service, so
  #that comments could manipulate themselves and their lists, and then presentation data would
  #just be manipulated in here.  This won't make any functional difference but
  #would better follow the best practice of Fat Services, skinny controllers.

  $scope.props =
    editingComment: false
    viewingRemainingComments: false
    showSpinner: false

  $scope.remainingCommentsCount = ->
    if($scope.list.comments)
      $scope.list.comments_count - $scope.list.comments.length
    else
      0
   $scope.searchPeople = (term) ->
     peopleList = [];
     return $http.get('/api/users.json', {params: {search: term}}).then (response) =>
       peopleList = response.data;
       $scope.people = peopleList;
       return $q.when(peopleList);

  $scope.getPeopleText = (item) ->
    return '@' + item.username

  $scope.confirmCommentDelete = ->
    comment = @comment
    list = @list

    deleteCommentModal = $modal.open
      templateUrl: "partials/confirm_delete_modal.html"
      controller: "ModalInstanceCtrl"

    deleteCommentModal.result.then (selectedItem) ->
      deleteComment(comment, list)
    , ->
      console.log "dismissed"

  $scope.addComment = ->
    data = {content: @comment.content, list_id: (@list.id || @list.cid)}
    data.cid = Comment.generateClientID()
    commentResource = new Comment(data)
    commentResource.intralist = true if @list.is_intralist
    commentResource.$save()
    data["username"] = $scope.current_user_name
    data["created_at"] = new Date
    data["created_at_in_words"] = "moments ago"
    data["image"] = $scope.current_user_image
    @list.comments.push(data)
    @list.comments_count += 1
    #Q: Isn't this setting an invalid state on the comment and so shouldn't be doable?
    @comment.content = ""

  #TODO: should perform this directly on the instance
  deleteComment = (comment, list) ->
    commentResource = new Comment(comment, list)
    commentResource.list_id = list.id || list.cid
    commentResource.intralist = true if list.is_intralist
    unless comment.id?
      commentResource.id = comment.cid
    commentResource.$destroy()
    i = list.comments.indexOf(comment)
    list.comments.splice(i, 1)
    list.comments_count -= 1

  $scope.updateComment = ->
    commentResource = new Comment(@comment)
    commentResource.list_id = @list.id || @list.cid
    commentResource.intralist = true if @list.is_intralist
    unless commentResource.id?
      commentResource.id = commentResource.cid
    commentResource.$update()
    $scope.props.editingComment = false
    @comment.editingComment = false

  $scope.editComment = ->
    $scope.props.editingComment = true
    @comment.editingComment = true

  $scope.fetchRemainingComments = ->
    list = @list
    $scope.props.showSpinner = true
    remaining_comments = Comment.query({list_id: @list.id}, (remainingComments) ->
      $scope.props.showSpinner = false
      list.comments = remaining_comments.concat(list.comments)
    )
    $scope.props.viewingRemainingComments = true

]
