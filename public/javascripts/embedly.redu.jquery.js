$.fn.enableEmbedding = function() {
  return this.each(function(){

    $(this).find('textarea').keyup(function(e) {
      var $this = $(this);

      if(e.which == 13 | e.which == 32) {
        // Usuário pressionou Enter ou Space
        var inLineLinks = parseUrl($this.val());
        if(inLineLinks != null){
          link = inLineLinks[0];
          var url = escape(link);
          var key = 'afbcb52a949111e1a1394040aae4d8c9';
          var api_url = 'http://api.embed.ly/1/oembed?key=' + key + '&url=' + url;//+ '&callback=?';
          if($this.data('last_url') != url){
            $this.data("last_url", url);
            $.getJSON(api_url, {crossDomain:  true}, function(json) {
              var resource_inputs = "";
              var thumbnail_list = [];

              // Processa thumbnails
              if(json.thumbnail_url != null) {
                if(json.thumbnail_url instanceof Array) {
                  for(e in json.thumbnail_url) {
                    thumbnail_list.push(json.thumbnail_url[e].url);
                  }
                } else {
                  thumbnail_list.push(json.thumbnail_url);
                }
                json.first_thumb = thumbnail_list[0];

                // Adiciona à lista de URL's de thumbnails
                $this.data("thumbnail_list", thumbnail_list);

                // Adiciona imagem de thumbnail (quando existe)
                resource_inputs = resource_inputs + appendInput("thumb_url", json.first_thumb);
              }

              resource_inputs = resource_inputs + appendInput("provider", json.provider_url);
              //Url shorted
              if(json.url != null) {
                resource_inputs = resource_inputs + appendInput("link", json.url);
              } else {
                resource_inputs = resource_inputs + appendInput("link", url);
                json.url = 'http://' + url;
              }
              //Title
              if(json.title != null) {
                resource_inputs = resource_inputs + appendInput("title", json.title);
              }
              //Description
              if(json.description != null) {
                resource_inputs = resource_inputs + appendInput("description", json.description);
              }
              //Render template
              $this.renderTemplate(json);
              $this.parents('fieldset').find('.post-resource').prepend(resource_inputs);
            });
          }
        }
      }
    });

    // Fechar conteúdo embedded
    $(this).find('.close').live('click', function(){
      $(this).parents('fieldset').find('textarea').data('last_url', "");
      $(this).parents('fieldset').find('.post-resource').slideUp(function(){
        $(this).remove();
      });
    });

    // Ações de navegação do thumbnail
    $(this).find('.buttons-thumbnail span').live('click', function(){
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
    $(this).find('input').live('click', function() {
      $(this).parents('fieldset').find("textarea").data('last_url', "");
      $(this).parents('fieldset').find('.post-resource').ajaxComplete(function() {
        $(this).slideUp(function(){
          $(this).remove();
        });
      });
    });
  });
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
