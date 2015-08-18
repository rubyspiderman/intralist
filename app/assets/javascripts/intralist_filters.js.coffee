intralist.filter "toTitleCase", ->
  (input) ->
    input.replace /\w\S*/g, (txt) ->
      txt.charAt(0).toUpperCase() + txt.substr(1).toLowerCase()

intralist.filter "hrefUrl", ->
  (url) ->
    if !/^https?:\/\//i.test(url)
      url = 'http://' + url
    else
      url

intralist.filter "cut", ->
  (value, wordwise, max, tail) ->
    return ""  unless value
    max = parseInt(max, 10)
    return value  unless max
    return value  if value.length <= max
    value = value.substr(0, max)
    if wordwise
      lastspace = value.lastIndexOf(" ")
      value = value.substr(0, lastspace)  unless lastspace is -1
    value + (tail or "…")

intralist.filter "userMention", ->
  (text) ->
    return "" unless text 
    filteredText= text
    regex = /(@\S+)/gi
    matches = text.match(regex)
    if(matches)
      matches.forEach (mention) ->
        mentionUrlText = mention.replace("@", "")
        mentionTag = "<a href='/"+mentionUrlText+ "'>"+mention+"</a>"
        filteredText = filteredText.replace(mention, mentionTag)
    return filteredText
