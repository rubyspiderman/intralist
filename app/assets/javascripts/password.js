var _INTRALIST = _INTRALIST || {};

_INTRALIST = (function($, window, document, I){
    I.Password = {
        clearForm: function(){
          $('#forgotPasswordModal form')[0].reset();
          $('#forgotPasswordModal p.header-message').html('').
              removeClass('bg-primary').
              removeClass('bg-danger')
        },
        resetPasswordModalInitialize: function(){
            var self = this;
            $('#forgotPasswordModal').modal({
                keyboard: true,
                show: false
            });

            $('#forgotPasswordModal').on('hide.bs.modal', function(e){
                //$('#loginModal').modal('show');
                self.clearForm();
            });

            $('#forgotPasswordModal').delegate('#back-to-login', 'click', function(e){
                $('#forgotPasswordModal').modal('hide');
                $('#loginModal').modal('show');
            })

            self.initializeModalSubmit()
        },

        initializeModalSubmit: function(){
          $('#forgotPasswordModal').delegate('#forgot-password-modal', 'submit', function(e){
              e.preventDefault();

              var ajaxOptions = {
                  url: $(this).attr('action'),
                  type: 'POST',
                  data: $(this).serialize(),
                  beforeSend: function(){
                      $('#forgotPasswordModal p.header-message').html('').
                          removeClass('bg-primary').
                          removeClass('bg-danger');
                  }
              };

              I.Ajax.sendRequest(ajaxOptions, function(response){
                  $('#forgotPasswordModal p.header-message').addClass('bg-primary').
                      removeClass('bg-danger').
                      html('We have sent you an email with instructions to reset your password');

                  window.setTimeout(function(){
                    $('#forgotPasswordModal').modal('hide');
                  }, 2000);
              }, function(err){
                  var errMessage;

                  if (err.status == 422){
                    var errorObj = JSON.parse(err.responseText);
                    errMessage = '';
                    for (key in errorObj.errors){
                        errMessage += key + " " + errorObj.errors[key];
                    }

                    if(errMessage == 'email not found')
                        errMessage = 'We were unable to find your email address.';
                  }

                  $('#forgotPasswordModal p.header-message').
                      addClass('bg-danger').
                      removeClass('bg-primary').
                      html(errMessage);

              });
          });
        },

        forgotPasswordRequest: function(){
            $('#loginModal').delegate('#forgot-password-modal-link', 'click', function(e){
                e.preventDefault();
                $('#loginModal').modal('hide');
                $('#forgotPasswordModal').modal('show');
            });
        }
    }

    $(function(){
        if($('body #forgotPasswordModal').length > 0){
            I.Password.resetPasswordModalInitialize();
            I.Password.forgotPasswordRequest();
        }
    })

    return _INTRALIST;
})(jQuery, this, this.document, _INTRALIST)
