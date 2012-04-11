$(document).ready(function(){
  $('textarea#status_text').keyup(function(e){
    var $this = $(this);
    if(e.which == 13 | e.which == 32) {
      var resultArray = parseUrl($this.val());
      if(resultArray != null){
        link = resultArray[0];
        var url = escape(link);
        var key = '1068f47e735911e181904040d3dc5c07';
        var api_url = 'http://api.embed.ly/1/oembed?key=' + key + '&url=' + url;//+ '&callback=?';
        if($this.data('last_url') != url){
          $this.data("last_url", url);
          //jQuery JSON call
          $.getJSON( api_url, {crossDomain:  true}, function(json) {
            var title = "";
            var description = "";
            var thumbnail_content = "";
            var thumbnail_navigation = "";
            var resource_inputs = "";
            var thumbnail_list = [];

            resource_inputs = resource_inputs + appendInput("provider", json.provider_url);
            if(json.url != null) {
              resource_inputs = resource_inputs + appendInput("link", json.url);
            } else {
              resource_inputs = resource_inputs + appendInput("link", json.url);
            }
            if(json.title != null) {
              title = json.title;
              resource_inputs = resource_inputs + appendInput("title", title);
            }
            if(json.description != null) {
              description = json.description;
              resource_inputs = resource_inputs + appendInput("description", description);
            }

            //Process thumbnails
            if(json.thumbnail_url != null) {
              if(json.thumbnail_url instanceof Array){
                for(e in json.thumbnail_url){
                  thumbnail_list.push(json.thumbnail_url[e].url);
                }
                thumbnail_navigation = '<span class="last">'+
                  '<span class="arrow">L</span>'+
                  '</span><span class="next">'+
                  '<span class="arrow">N</span></span>';
              } else {
                thumbnail_list.push(json.thumbnail_url);
              }

              //Add url list
              $this.data("thumbnail_list", thumbnail_list);

              //Add thumbnail img when thumbnail exists
              resource_inputs = resource_inputs + appendInput("thumb_url", thumbnail_list[0]);
              thumbnail_content = '<div class="thumbnail">'+
                '<span class="preview-link">'+
                '<img id="thumbnail-0" src="'+thumbnail_list[0] +'"/>"</span>'+
                thumbnail_navigation +
                '<span class="remove">'+
                '<span class="arrow">R</span>'+
                '</span>'+
                '</div>';
            }

            //Preview box
            $this.parents('fieldset').find('.new-post.vis-new-post').remove();
            $('<div class="new-post vis-new-post">'+
                resource_inputs + thumbnail_content +
                '<div class="description">'+
                '<span class="close icon-small icon-delete-gray_8_10">Close</span>'+
                '<h2 class="title">'+title+'</h2>'+
                '<h3 class="link">'+json.provider_url+'</h3>'+
                '<p>'+description+'</p>'+
                '</div>'+
                '</div>'
             ).insertAfter($this);
          });
        }

      }}
  });

  //close embedded content
  $('fieldset .description span.close.icon-small').live('click', function(){
    $(this).parents('fieldset').find("textarea#status_text").data('last_url', "");
    $(this).parents('fieldset').find('.new-post.vis-new-post').slideUp(function(){
      $(this).remove();
    });
  });

  //next thumbnail
  $('fieldset .thumbnail span').live('click', function(){
    var button = $(this);
    var thumbnail_list = button.parents("fieldset").find("textarea#status_text").data("thumbnail_list");
    if(button.hasClass('remove')){
      button.parents('fieldset').find('.thumbnail').fadeOut();
      button.parents('fieldset').find('input#resource_thumb_url').remove();
    } else if(button.hasClass('next')) {
      updateThumbnail(button, thumbnail_list, true);
    } else if(button.hasClass('last')) {
      updateThumbnail(button, thumbnail_list, false);
    }
  });
});

function updateThumbnail(root, thumbnail_list, get_next) {
  var img = root.parents('fieldset').find('.thumbnail .preview-link img');
  var id = img[0].id.split('-')[1];

  if(get_next){
    var next_id = parseInt(id) + 1;
    if(next_id == thumbnail_list.length) { next_id = next_id -1; }
  } else {
    var next_id = parseInt(id) - 1;
    if(next_id < 0) { next_id = 0; }
  }
  img.attr('src', thumbnail_list[next_id]);
  img.attr('id', 'thumbnail-' + next_id);
  root.parents('fieldset').find('input#resource_thumb_url').attr('value', thumbnail_list[next_id]);
}

function appendInput(name, value){
  return '<input id="resource_'+ name +'" type="hidden" name="resource['+ name + ']" value="'+ value +'"/>';
}

function parseUrl(text){
  var regex = /(\b(((https?|ftp|file):\/\/)|(www))[\-A-Z0-9+&@#\/%?=~_|!:,.;]*[\-A-Z0-9+&@#\/%=~_|])/ig;
  var resultArray = text.match(regex);
  return resultArray;
}
