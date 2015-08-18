$ ->
  #stick in the fixed 100% height behind the navbar but don't wrap it
  $("#slide-nav.navbar .container").append $("<div id=\"navbar-height-col\"></div>")

  # Enter your ids or classes
  toggler = ".navbar-toggle"
  pagewrapper = "#page-content"
  navigationwrapper = ".navbar-header"
  menuwidth = "100%" # the menu inside the slide menu itself
  slidewidth = "80%"
  menuneg = "-100%"
  slideneg = "-80%"
  $("#slide-nav").on "click", toggler, (e) ->
    selected = $(this).hasClass("slide-active")
    $("#slidemenu").stop().animate left: (if selected then menuneg else "0px")
    $("#navbar-height-col").stop().animate left: (if selected then slideneg else "0px")
    $(pagewrapper).stop().animate left: (if selected then "0px" else slidewidth)
    $(navigationwrapper).stop().animate left: (if selected then "0px" else slidewidth)
    $(this).toggleClass "slide-active", not selected
    $("#slidemenu").toggleClass "slide-active"
    $("#page-content, .navbar, body, .navbar-header").toggleClass "slide-active"

  selected = "#slidemenu, #page-content, body, .navbar, .navbar-header"
  $(window).on "resize", ->
    $(selected).removeClass "slide-active"  if $(window).width() > 767 and $(".navbar-toggle").is(":hidden")
