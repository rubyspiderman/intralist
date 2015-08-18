var _INTRALIST = _INTRALIST || {};

_INTRALIST = (function($, window, document, I){
    I.Search = {
        searchMore: function(){
             window.location.href = '/search?q=' + $('.search-input').val();
        },

        redirectHandler: function(){
            $('body').delegate('.tt-suggestion', 'click', function(e){
                e.preventDefault();
                var uri = $(this).find('.suggestion-box').last().data('url');
                window.location.href= uri;
            });
        },

        enable: function(){
           var s = 'suggestion';
           $('.search-input').typeahead({
               minLength:3,
               highlight: true,
               hint: false
           },{
              source: function(q, cb){

                  var ajaxOptions = {
                      url: '/search?q=' + q
                  };

                  I.Ajax.sendRequest(ajaxOptions, function(response){
                      cb(response.results);

                  }, function(err){});
              },
              name: 'search',
              displayKey: 'title',
              templates: {
                  suggestion: Handlebars.compile('<div class="suggestion-box" data-url="{{type_url}}">' +
                                '<div class="suggestion-logo">' +
                                  '<img src="{{type_icon}}" class="suggestion-logo-img"/>' +
                                 '</div>' +
                                 '<div class="suggestion-message">{{title}} ' +
                                   '<br>' +
                                   '<span style="color:#939598;">{{sub_text}}</span></div>' +
                                 '</div><div class="clearfix"></div>'),
                  footer: '<div class="suggestion-footer"><a href=\'#\' onclick="_INTRALIST.Search.searchMore(); return false;">See more results </a></div>'

              }
           })
        },

        enableSearchViaRedirect: function(){
            $('#primary-search').delegate('.search-submit', 'click', function(e){
                e.preventDefault();
                $('#primary-search').submit();
            });
        },


        searchPageRedirectHandler: function(){
            $('body').delegate('.user-block', 'click', function(e){
                e.preventDefault();
                var redirectUrl = $(this).data('url');
                window.location.href = redirectUrl;
            })
        }
    };


    $(function(){
        if ($('.search-input').length > 0){
          I.Search.enable();
          I.Search.redirectHandler();
          I.Search.enableSearchViaRedirect();
        }

        if($('.user-block').length > 0)
            I.Search.searchPageRedirectHandler();
    });

    return I;
})(jQuery, this, this.document, _INTRALIST);