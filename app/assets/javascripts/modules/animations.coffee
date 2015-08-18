#Q: Why aren't these firing when used on list items when editing?
#TODO: implement or use a more angulary version
intralist.animation ".slideDown", ->
  addClass: (element, className, done) ->
    jQuery(element).slideDown ->
      jQuery(element).css({'overflow': 'visible'})
      done()
    return

  removeClass: (element, className, done) ->
    jQuery(element).slideUp done
    return
