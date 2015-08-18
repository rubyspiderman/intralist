var _INTRALIST = _INTRALIST || {};

_INTRALIST = (function($, window, document, I){

    // Wrapper around basic Jquery Ajax options
    I.Ajax = {
        sendRequest: function(options, callback, errback){
            var ajaxOptions = {
                url:'/',
                type:'GET',
                dataType:'json',
                success: function(response){
                    callback(response);
                },
                error: function(response){
                    if(errback != undefined){
                        errback(response);
                    }
                }
            }

            if(options)
                $.extend(ajaxOptions, options);

            var xhr;
            xhr = $.ajax(ajaxOptions);
            return xhr;
        },

        // Basic wrapper around standard Jquery Jsonp request.
        sendJSONp: function(url, data, callback){
            url += '?callback=?'
            $.getJSON(url, data, function(data){
                callback(data);
            });
        }
    };


    $(function(){

    })
    return _INTRALIST;
})(jQuery, this, this.document, _INTRALIST);