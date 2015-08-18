intralist.factory 'autoCompletion', [ '$timeout', ($timeout) ->
  bloodhound = new Bloodhound
    name: 'tags',
    local: [{name: 'tag1', count: 10}, {name: 'tag2', count: 20}]
    datumTokenizer: (d) -> Bloodhound.tokenizers.whitespace(d.name)
    queryTokenizer: Bloodhound.tokenizers.whitespace
    limit: 20
    prefetch: {url: "/tags.json"}

  bloodhound.initialize()

  #fetchListNames = (query) ->

  #fetchItemNames = (query) ->

  fetchTags: (query) ->
    suggestionsArray = []
    bloodhound.get query, (suggestions) ->
      suggestions.forEach (suggestion) -> suggestionsArray.push(suggestion.name)
    deferred = jQuery.Deferred()
    $timeout ->
      deferred.resolve(suggestionsArray)
    , 0
    deferred
]
