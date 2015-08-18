var _INTRALIST = _INTRALIST || {};

_INTRALIST = (function($, window, document, I){
    I.Login = {
        enableCompleteRegistrationModal: function(){
            $('#completeRegistrationModal').delegate('#complete-registration-modal', 'submit', function(evt){
                evt.preventDefault();

                var ajaxOptions = {
                    url: $(this).attr('action'),
                    type: 'POST',
                    data: $(this).serialize()
                };

                I.Ajax.sendRequest(ajaxOptions, function(response){
                    if(response.id){
                        $('#completeRegistrationModal p.header-message').removeClass('bg-danger').
                            addClass('bg-primary').html("<span><strong> Sweet! Logging you in...</strong></span>");

                        window.location.reload();
                    }
                }, function(err){

                    if(err.responseText){
                        var error = JSON.parse(err.responseText);
                        var errorText = "";

                        for(message in error.errors){
                            errorText += "<span><strong>" + message + ":</strong> " + error.errors[message].toString() +  "</span>"
                        }
                        $('#completeRegistrationModal p.header-message').removeClass('bg-primary').
                            addClass('bg-danger').html(errorText);
                    }
                });

            })
        },

        enableFacebookLogin: function(){
            $('#loginModal, #registerModal').delegate('.facebook-login-link', 'click', function(evt){
               evt.preventDefault();
                $('#loginModal, #registerModal').modal('hide');

                FB.login(function(response){
                   if(response.authResponse){
                       $.getJSON('/users/auth/facebook/callback', function(json){

                         if (json.request_status == 'success'){
                             if(json.user_exists){
                                window.location.reload();
                             }else{
                                 $('#completeRegistrationModal p.header-message').removeClass('bg-danger').
                                     addClass('bg-primary').
                                     html("Welcome " + json.data.info.name + "!, We need a username and password to get you on your way");
                                 $('#completeRegistrationModal .facebook-image').html('<img src=' + json.data.info.image + '/>');
                                 $('#completeRegistrationModal').modal('show');
                                 $('#complete-registration-modal .complete-registration-form-email').val(json.data.info.email)
                                 $('#complete-registration-modal .complete-registration-form-dob').val(json.data.info.birthday)
                             }
                         }else{
                           $('#completeRegistrationModal p.header-header').
                                            removeClass('bg-primary').
                                            addClass('bg-danger').
                                            html("Something seems to have gone wrong while fetching your data from Facebook")

                         }


                       })
                   }
                }, {scope: 'email, public_profile, read_stream'});
            });
        },

        enableFormLogin: function(){
            $('#loginModal').delegate('#form-login', 'submit', function(e){
                e.preventDefault();

                var ajaxOptions = {
                    url: $(this).attr('action'),
                    type: "POST",
                    data: $(this).serialize(),
                    beforeSend: function(){
                        $('#loginModal #form-login p.header-message').
                            removeClass('bg-danger bg-primary').
                            html('');
                    }
                };

                I.Ajax.sendRequest(ajaxOptions, function(response){
                   $('#loginModal #form-login p.header-message').
                       removeClass('bg-danger').addClass('bg-primary').
                       html('Sweet! Logging you in...');
                    window.setTimeout(function(){
                        window.location.reload();
                    }, 1000)

                }, function(err){
                    var errObj = JSON.parse(err.responseText);
                    var errMessage;

                    if (err.status == 401){
                        errMessage = errObj.error;
                    }else{
                        errMessage = 'Invalid username or password'
                    }

                    $('#loginModal #form-login p.header-message').addClass('bg-danger').
                        removeClass('bg-primary').
                        html(errMessage);
                });
            })
        }
    };


    // On ready
    $(function(){
        window.fbAsyncInit = function() {
            FB.init({
                appId: _FB_APP_ID,
                xfbml: true,
                cookie: true,
                version: 'v2.0'
            });
        };

        (function(d, s, id){
            var js, fjs = d.getElementsByTagName(s)[0];
            if (d.getElementById(id)) {return;}
            js = d.createElement(s); js.id = id;
            js.src = "//connect.facebook.net/en_US/sdk.js";
            fjs.parentNode.insertBefore(js, fjs);
        }(document, 'script', 'facebook-jssdk'));



        if($('#loginModal .facebook-login-link').length > 0) {
            I.Login.enableFacebookLogin();
            I.Login.enableCompleteRegistrationModal();
        }

        if($('#loginModal #form-login').length > 0){
            I.Login.enableFormLogin();
        }
    })

    return _INTRALIST;
})(jQuery, this, this.document, _INTRALIST)
