var _INTRALIST = _INTRALIST || {};

_INTRALIST = (function($, window, document, I){
    I.Registration = {

      addErrorMessage: function(message){
        $('#new_user .header-message').addClass('bg-danger').
           removeClass('bg-primary').html(message);
      },

      addSuccessMessage: function(message){
        $('#new_user .header-message').removeClass('bg-danger').
            addClass('bg-primary').html(message);
      },

      enableAjaxRegistrationModal: function(){
        var self = this;
        $('#registerModal').delegate('#new_user', 'submit', function(evt){
           evt.preventDefault();

           var ajaxOptions = {
             url: $(this).attr('action'),
             type: 'POST',
             data: $(this).serialize()
           };

            I.Ajax.sendRequest(ajaxOptions, function(response){
                if(response.id){
                    var message = 'Creating your account and logging you in';
                    self.addSuccessMessage(message);
                    window.setTimeout(function(){
                        window.location.reload();
                    }, 2000)

                }
            }, function(err){
                var errorMessage = '';
                if(err.status == 422){
                    var errorMessageText = JSON.parse(err.responseText);

                    for(field in errorMessageText.errors){
                        errorMessage += "<span><strong>" + field + "</strong></span>: " +
                                        errorMessageText.errors[field] + " <br/>";
                    }
                }else{
                    errorMessage = err.responseText;
                }
                self.addErrorMessage(errorMessage);
            })
        });
      }


    };

    $(function(){
       if ($('#registerModal .registration-form').length > 0){
           I.Registration.enableAjaxRegistrationModal();
       }
    });


    return I;
})(jQuery, this, this.document, _INTRALIST);