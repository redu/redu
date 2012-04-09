$(document).ready(function(){
  $('.create-status.inform-my-status .status.textarea').keyup(function(e){
    if(e.which == 13 | e.which == 32) {
    var text = $(this).val();
    var regex = /(\b(((https?|ftp|file):\/\/)|(www))[\-A-Z0-9+&@#\/%?=~_|!:,.;]*[\-A-Z0-9+&@#\/%=~_|])/ig;
    var resultArray = text.match(regex);
      if(resultArray != null){
        link = resultArray[0];
        console.log(link);
        var url = escape(link);
        var key = '1068f47e735911e181904040d3dc5c07';
        var api_url = 'http://api.embed.ly/1/oembed?key=' + key +
                      '&url=' + url;
                      //+ '&callback=?';
        //jQuery JSON call
        $.getJSON( api_url, {crossDomain:  true}, function(json) {
            console.log(json);

            var thumbnail_content = "";
            var thumbnail_list = [];
            if(json.thumbnail_url != null) {
              if(json.thumbnail_url instanceof Array){
                for(el in json.thumbnail_url){
                  thumbnail_list.push(json.thumbnail_url[el].url);
                }
              } else {
                thumbnail_list.push(json.thumbnail_url);
              }
              thumbnail_content = '<div class="thumbnail">'+
                    '<span class="preview-link">'+
                      '<img id="thumbnail-" src="'+thumbnail_list[0] +'"/>"</span>'+
                    '<span class="last">'+
                      '<span class="arrow">L</span>'+
                    '</span>'+
                    '<span class="next">'+
                      '<span class="arrow">N</span>'+
                    '</span>'+
                    '<span class="remove">'+
                      '<span class="arrow">R</span>'+
                    '</span>'+
                  '</div>';
            }

            $('fieldset .new-post.vis-new-post').remove();
            $('<div class="new-post vis-new-post">'+
                thumbnail_content +
                '<div class="description">'+
                  '<span class="close icon-small icon-delete-gray_8_10">Close</span>'+
                  '<h2 class="title">'+json.title+'</h2>'+
                  '<h3 class="link">'+json.url+'</h3>'+
                  '<p>'+json.description+'</p>'+
                '</div>'+
              '</div>'
            ).insertAfter('textarea.status.textarea');
            $('.description span.close.icon-small').click(function(){
              $('fieldset .new-post.vis-new-post').slideUp();
            });
        });
      }
    }
  });
});
