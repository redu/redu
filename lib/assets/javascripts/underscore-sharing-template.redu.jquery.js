$.fn.renderTemplate = function(json) {
  $this = $(this);

  //Remove o preview
  $this.find('.post-resource').remove();

  var $preview = $('#template-preview').clone();

  //Adiciona a imagem do thumbnail no template
  //(devido ao erro no firefox não renderizar o template)
  $preview.find('img.preview-link').attr("src", json.first_thumb);

  //Adiciona a url do link no template
  //(devido ao erro no firefox não renderizar o template)
  $preview.find("a.title").attr("href", json.url);

  //Renderiza template
  var template = $preview.html();

  //Configs template (scriptlets)
  _.templateSettings = {
    interpolate: /\{\{\=(.+?)\}\}/g,
    evaluate: /\{\{(.+?)\}\}/g
  };
  var compiled = _.template(template);
  var rendered = compiled(json);

  //Adicona o template compilado
  $this.find('textarea').after(rendered);

  // Fechar conteúdo embedded
  $this.find('.close').live('click', function(e){
    var $parents = $(this).closest('form');
    $parents.find('textarea').data('last_url', "");
    $parents.find('.post-resource').slideUp(150, "swing", function(){
      $(this).remove();
    });
    e.preventDefault();
  });

  // Ações de navegação do thumbnail
  $this.find('.buttons .button-default').live('click', function(){
    var $button = $(this);
    var $parents = $button.closest('form');
    var thumbnail_list = $parents.find("textarea").data("thumbnail_list");
    if($button.hasClass('remove')){
      $parents.find('.preview').fadeOut();
      $parents.find('#resource_thumb_url').remove();
    } else if($button.hasClass('next')) {
      updateThumbnail($button, thumbnail_list, true);
    } else if($button.hasClass('last')) {
      updateThumbnail($button, thumbnail_list, false);
    }
  });

  // Faz desaparecer o preview depois de criar a postagem
  $this.find('input:submit').live('click', function() {
    var $parents = $(this).closest('form');
    $parents.find("textarea").data('last_url', "");
    $parents.find('.post-resource').ajaxComplete(function() {
      $(this).slideUp(function(){
        $(this).remove();
      });
    });
  });
}

// Atualiza o thumbnail do recurso de acordo com a resposta do embedly
function updateThumbnail(root, thumbnail_list, get_next) {
  var img = root.closest('form').find('.thumbnail img.preview-link');
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
  root.closest('form').find('#resource_thumb_url').attr('value', thumbnail_list[next_id]);
}
