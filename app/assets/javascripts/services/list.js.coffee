intralist.factory 'List', ['$resource', '$http', ($resource, $http) ->
  List = $resource("/api/lists/:id", {id: "@id"}, update: {method: "PUT"})

  #associations
  Like = $resource("/api/lists/:list_id/like", {list_id: "@list_id"})
  Bookmark = $resource("/api/lists/:list_id/bookmark", {list_id: "@list_id"})

  List.newList = (params) ->
    list = new List(params)
    list.items = []
    list.tags = []
    for i in [1..5]
      list.addEmptyItem()
    list.name ||= ''
    list

  List.createList = (list, copiedList, user) ->
    if list.copy
      list.parent_list_id = copiedList.id
      list.parent_list_creator = copiedList.user.username
      list.intralist_id = copiedList.intralist_id
      delete list.id

    non_blank_items = []
    for item in list.items
      non_blank_items.push(item) unless item.name == ""
    list.items = non_blank_items
    list.user = user

    list.created_at_in_words = "moments ago"
    listData = $.extend({}, list)
    listData.cid = List.generateClientID()
    listData.comments = []
    listData.likes_count = 0
    listData.bookmarks_count = 0
    listData.comments_count = 0

    listResource = new List(listData)
    listResource.$save()
    #TODO: Should pull in the other lists from this list group
    listGroup = listResource
    listGroup.lists = [angular.copy(listResource)]
    listGroup

  List::toggleLike = ->
    like = new Like({list_id: this.id || this.cid})
    like.intralist = true if @is_intralist
    #NOTE: These will either create or delete
    like.$save()
    if this.liked_by_me
      this.likes_count = this.likes_count - 1
    else
      this.likes_count = this.likes_count + 1

    this.liked_by_me = !this.liked_by_me

  List::toggleBookmark = ->
    bookmark = new Bookmark({list_id: this.id || this.cid})
    bookmark.intralist = true if @is_intralist
    bookmark.$save()
    if this.bookmarked_by_me
      this.bookmarks_count = this.bookmarks_count - 1
    else
      this.bookmarks_count = this.bookmarks_count + 1

    this.bookmarked_by_me = !this.bookmarked_by_me

  #TODO: wire up for intralists
  List.generateClientID = -> return Math.random().toString(36).substring(9)

  List::addEmptyItem = ->
    this.items.push({name: "", link: undefined, image_url: undefined})

  List::removeItem = (index) ->
    this.items.splice(index, 1)

  List::clearDescriptions = ->
    this.description = ""
    this.items.forEach (item) ->
      item.description = ""

  List
]
