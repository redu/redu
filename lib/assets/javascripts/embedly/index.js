// Necessita que o underscore tenha sido incluído anteriormente.
//= require underscore-sharing-template


$(function() {
  $.refreshEmbeddedSharing = function() {
    $(".status-tab").enableEmbedding();
  }

  $(document).ajaxComplete(function() {
    $.refreshEmbeddedSharing();
  });

  $.refreshEmbeddedSharing();
});

// Permite ao usuário embutir recursos (links, imagens, vídeos, etc.) em suas postagens.
$.fn.enableEmbedding = function() {

  return this.each(function() {
    var $this = $(this);
    var $textarea = $this.find("textarea");

    // Associa callback ao evento de pressionar teclas.
    $textarea.keyup(function(e) {
      var inLineLinks = parseUrl($textarea.val());

      if (inLineLinks != null) {
        var link = inLineLinks[0];
        var url = escape(link);
        var key = "afbcb52a949111e1a1394040aae4d8c9";
        var api_url = "http://api.embed.ly/1/oembed?key=" + key + "&url=" + url;

        if ($textarea.data("last_url") != url) {
          $textarea.data("last_url", url);

          $.ajax({
            cache: false,
            url: api_url,
            dataType: "jsonp",
            success: function(json) {
              var resource_inputs = "";
              var thumbnail_list = [];

              // Processa thumbnails.
              if (json.thumbnail_url != null) {
                if (json.thumbnail_url instanceof Array) {
                  for (e in json.thumbnail_url) {
                    thumbnail_list.push(json.thumbnail_url[e].url);
                  }
                } else {
                  thumbnail_list.push(json.thumbnail_url);
                }
                json.first_thumb = thumbnail_list[0];

                // Adiciona à lista de URL"s de thumbnails.
                $textarea.data("thumbnail_list", thumbnail_list);

                // Adiciona imagem de thumbnail (quando existe)
                resource_inputs = resource_inputs + appendInput("thumb_url", json.first_thumb);
              }

              resource_inputs = resource_inputs + appendInput("provider", json.provider_url);

              // URL encurtada.
              if (json.url != null) {
                resource_inputs = resource_inputs + appendInput("link", json.url);
              } else {
                resource_inputs = resource_inputs + appendInput("link", link);
                json.url = link;
              }

              // Título.
              if (json.title != null) {
                resource_inputs = resource_inputs + appendInput("title", json.title);
              }

              // Descrição.
              if (json.description != null) {
                resource_inputs = resource_inputs + appendInput("description", json.description.replace(/"/g, "'"));
              }

              // Renderiza o template.
              if (json.type != "error") {
                $this.renderTemplate(json);
                $textarea.closest("form").find(".post-resource").prepend(resource_inputs);
              }
            }
          });
        }
      }
    });
  });
}

// Inclui informações necessárias (em inputs escondidos) à requisição HTTP.
function appendInput(name, value) {
  return '<input id="resource_'+ name +'" type="hidden" name="status[status_resources_attributes][]['+ name + ']" value="'+ value +'"/>';
}

// Detecta links no texto de entrada do usuário e os retorna num array.
function parseUrl(text) {
  var regex = /(\b(((https?|ftp|file):\/\/)|(www))[\-A-Z0-9+&@#\/%?=~_|!:,.;]*[\-A-Z0-9+&@#\/%=~_|])/ig;
  var resultArray = text.match(regex);

  return resultArray;
}