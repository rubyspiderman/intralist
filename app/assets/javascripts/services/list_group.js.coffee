intralist.factory 'ListGroup', ['$resource', '$http', 'List', 'Request', ($resource, $http, List, Request) ->
  ListGroup = $resource("/api/list_groups/:id")

  ListGroup.newRequestListGroup = (request) ->
    list_group = new ListGroup()
    list_group.request = request
    list_group.lists = []
    list_group

  ListGroup::bubbleUsersList = (user) ->
    userListIndex = -1
    userList = null

    lists = this.lists
    lists.forEach (element, index, array) ->
      if element.user.username == user.username
        userListIndex = index
        userList = element
        lists.splice(userListIndex, 1)
        lists.unshift(userList)
        return false

  ListGroup::bubbleListBySlug = (slug) ->
    listIndex = -1
    list = null

    this.lists.forEach (element, index, array) ->
      if element.slug == slug
        listIndex = index
        list = element
    this.lists.splice(listIndex, 1)
    this.lists.unshift(list)

  ListGroup.castLists = (list_groups) ->
    list_groups.forEach (list_group) ->
      if list_group.intralist
        list_group.intralist = new List(list_group.intralist)

      if list_group.request
        list_group.request = new Request(list_group.request)

      lists = list_group.lists.map ( (list) -> new List(list) )
      list_group.lists = lists

  ListGroup
]
