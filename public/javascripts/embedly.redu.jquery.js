$.fn.catchAndSendToEmbedly = function() {
  $('textarea#status_text').keyup(function(e){
    var $this = $(this);
    if(e.which == 13 | e.which == 32) {
      // Usuário pressionou Enter ou Space
      var inLineLinks = parseUrl($this.val());
      if(inLineLinks != null){
        link = inLineLinks[0];
        var url = escape(link);
        var key = '1068f47e735911e181904040d3dc5c07';
        var api_url = 'http://api.embed.ly/1/oembed?key=' + key + '&url=' + url;//+ '&callback=?';
        if($this.data('last_url') != url){
          $this.data("last_url", url);
          $.getJSON(api_url, {crossDomain:  true}, function(json) {
            var title = "";
            var description = "";
            var thumbnail_content = "";
            var thumbnail_navigation = "";
            var resource_inputs = "";
            var thumbnail_list = [];

            resource_inputs = resource_inputs + appendInput("provider", json.provider_url);
            if(json.url != null) {
              resource_inputs = resource_inputs + appendInput("link", json.url);
              url = json.url
            } else {
              resource_inputs = resource_inputs + appendInput("link", url);
              url = 'http://' + url;
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
                thumbnail_navigation = '<span class="last control">'+
                  '<span class="arrow">L</span>'+
                  '</span><span class="next control">'+
                  '<span class="arrow">N</span></span>';
              } else {
                thumbnail_list.push(json.thumbnail_url);
              }

              //Add thumbnail's urls list
              $this.data("thumbnail_list", thumbnail_list);

              //Add thumbnail img when thumbnail exists
              resource_inputs = resource_inputs + appendInput("thumb_url", thumbnail_list[0]);
              thumbnail_content = '<div class="thumbnail">'+
                '<img id="thumbnail-0" class="preview-link" src="'+thumbnail_list[0] +'"/>'+
                '<span class="buttons-thumbnail">'+
                  thumbnail_navigation +
                  '<span class="remove control">'+
                  '<span class="arrow">R</span>'+
                '</span>'+
                '</div>';
            }

            //Preview box
            $this.parents('fieldset').find('.post-resource').remove();
            $('<div class="post-resource">'+resource_inputs +
                '<hr class="border-post concave-separator"/>' +
                 thumbnail_content +
                '<div class="post-text">' +
                  '<span class="close icon-small icon-delete-gray_8_10">Close</span>'+
                  '<h3><a href="'+ url +'" target="_blank" rel="nofollow" class="title">'+title+'</a></h3>'+
                  '<h4 class="source-site">'+json.provider_url+'</h4>'+
                  '<p class="post-description">'+description+'</p>'+
              '</div>'+
                '<hr class="border-post concave-separator"/>' +
                '</div>'
             ).insertAfter($this);
            if (json.thumbnail_url == null){
              $this.parents('fieldset').find('.post-resource').addClass('no-preview');
            }
          });
        }

      }}
  });

  // Close embedded content
  $('fieldset .post-text span.close.icon-small').live('click', function(){
    $(this).parents('fieldset').find("textarea#status_text").data('last_url', "");
    $(this).parents('fieldset').find('.post-resource').slideUp(function(){
      $(this).remove();
    });
  });

  // Navigation thumbnail actions
  $('fieldset .thumbnail .buttons-thumbnail span').live('click', function(){
    var button = $(this);
    var thumbnail_list = button.parents("fieldset").find("textarea#status_text").data("thumbnail_list");
    if(button.hasClass('remove')){
      button.parents('fieldset').find('.thumbnail').fadeOut();
      button.parents('fieldset').find('input#resource_thumb_url').remove();
      button.parents('fieldset').find('.post-resource').addClass('no-preview');
    } else if(button.hasClass('next')) {
      updateThumbnail(button, thumbnail_list, true);
    } else if(button.hasClass('last')) {
      updateThumbnail(button, thumbnail_list, false);
    }
  });

  // Faz desaparecer o preview depois de criar a postagem
  $('input#status_submit').live('click', function() {
    $(this).parents('fieldset').find("textarea#status_text").data('last_url', "");
    $(this).parents('fieldset').find('.post-resource').ajaxComplete(function() {
      $(this).slideUp(function(){
        $(this).remove();
      });
    });
  });
}

// Atualiza o thumbnail do recurso de acordo com a resposta do embedly
function updateThumbnail(root, thumbnail_list, get_next) {
  var img = root.parents('fieldset').find('.thumbnail img.preview-link');
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

// Inclui informações necessárias (em inputs escondidos) à requisição HTTP
function appendInput(name, value){
  return '<input id="resource_'+ name +'" type="hidden" name="status[status_resources_attributes][]['+ name + ']" value="'+ value +'"/>';
}

// Deteta links no texto de entrada do usuário e os retorna num array
function parseUrl(text){
  var regex = /(\b(((https?|ftp|file):\/\/)|(www))[\-A-Z0-9+&@#\/%?=~_|!:,.;]*[\-A-Z0-9+&@#\/%=~_|])/ig;
  var resultArray = text.match(regex);
  return resultArray;
}

// Carrega o JavaScript tanto para requisições remotas quanto para não-remotas
$(document).ready(function(){
  $(document).catchAndSendToEmbedly();

  $(document).ajaxComplete(function(){
    $(document).catchAndSendToEmbedly();
  });
});
