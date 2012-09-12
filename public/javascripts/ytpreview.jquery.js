(function($){
    $.fn.ytPreview = function(options){
      var utils = {
        titleField : "#title-field",
        appendTo : "#youtube_preview",
        ytEmbed : function(){
          return $("<iframe/>",
            { "width" : 425, "height" : 349, "src" : "", "frameborder" : 0, "allowfullscreen" : "", "id" : "yt-preview" })
        },
        urlRegex : new RegExp("((http|https)(:\/\/))?([a-zA-Z0-9]+[.]{1}){2}[a-zA-z0-9]+(\/{1}[a-zA-Z0-9]+)*\/?", "i"),
        isURL : function(value){
          return this.urlRegex.test(value);
        },
        ytCode : function(value){
          var result = value.match(/http\:\/\/(m|w{3})\.youtube\.com\/\S*v=([A-Za-z0-9-_]{11})/);
          return (result === null) ? false : result[2]
        },
        ytEmbedURL : function(code){
          return "http://www.youtube.com/embed/" + code;
        },
        ytAPI : function(code){
          return "https://gdata.youtube.com/feeds/api/videos/" + code;
        },
        escapeSelectors : function(myid) {
          return '#' + myid.replace(/[-[\]{}()*+?.,\\^$|#\s]/g, "\\$&");
        }
      }

      var settings = $.extend(utils, options);

      return this.each(function(){
          var $this = $(this);

          $this.bind("input", function(){
              var value = $(this).val();
              var name = $this.attr("name");

              $(settings.escapeSelectors(name)).remove();
              $(settings.titleField).val("");

              if(settings.isURL(value)){
                var ytCode = settings.ytCode(value);
                var $ytEmbed = settings.ytEmbed().clone().attr("id", name);

                if(ytCode) {
                  $.get(settings.ytAPI(ytCode), { "v" : 2, "alt" : "json"}, function(data){
                      $(settings.titleField).val(data.entry.title["$t"]);
                  }, "jsonp");

                  // Removendo wrapper anterior, se houver e adicionado o novo iframe
                  $ytEmbed.attr("src", settings.ytEmbedURL(ytCode));
                  $(settings.appendTo).append($ytEmbed);
                }
              }
          });
      });
    }
})(jQuery);
