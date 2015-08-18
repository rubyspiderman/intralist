
# TODO: This is throwing an error.  Remove if not needed
# $ ->
  # $stickyEl = $("#right-column")
  # elTop = $stickyEl.offset().top
  # $(window).scroll ->
    # $stickyEl.toggleClass "sticky", $(window).scrollTop() > elTop

$ ->
  $.ajaxSetup beforeSend: (xhr) ->
    xhr.setRequestHeader "X-CSRF-Token", $("meta[name=\"csrf-token\"]").attr("content")
    return
  $('#user-notifications').on 'show.bs.dropdown', ->
    $('.notifications-indicator').remove()
  $('#user-notifications').on 'hidden.bs.dropdown', ->
    $('.notifications-list').find('.media').addClass('read-notification')
    lastNotificationId = $('.notifications-list').find('.media:first').attr('data-notification-id') 
    $.ajax(
      type: "Put"
      url: "/api/users/" + window.current_user_name
      data:
        user:
          last_notification_id: lastNotificationId
    ).done () ->
      return
  $('.clear-notifications').live "click", (e) ->
    e.preventDefault()
    $.ajax(
      type: "Delete"
      url: "/api/notifications/"
    ).done () ->
      $('.glyphicon-bell').unwrap();
    
    # let's do an ajax call to the user model and update the last_notification_id with the first here...
    # Add a data attribute here data-notification-id which stores the notification-id
    # grab the first with Ajax, and send it in the request
  $('.clear-notifications').on  "ajax:success", (e, data, status, xhr) ->
    # this doesn't actually work yet
    alert "Notifications were deleted"

  $('.authenticate').live "click", (e) ->
    e.preventDefault()
    $("#loginModal").modal('show')   
      
  $('.switch-reg').click (e) ->
    e.preventDefault()
    $("#loginModal").modal('hide').one 'hidden.bs.modal', (e) ->
      $("#registerModal").modal('show')
  
  $('.switch-login').click (e) ->
    e.preventDefault()
    $("#registerModal").modal('hide').one 'hidden.bs.modal', (e) ->
      $("#loginModal").modal('show')    
      
  $('.form-signup').click (e) ->
    e.preventDefault()
    $('.registration-form').slideToggle()
  $('.show-password-fields').click (e) ->
    e.preventDefault()
    $('.password-fields').slideToggle()



changeContext = (li) ->
  $(li).toggleClass("active")
  $(li).next().stop().slideToggle()
