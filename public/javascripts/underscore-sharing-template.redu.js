$.fn.renderTemplate = function(json) {
  $this = $(this);

  //Preview box
  $this.find('.post-resource').remove();

  //Render template
  var $template = $('#template-preview').html();

  console.log(json);
  //Configs template (scriptlets)
  _.templateSettings = {
    interpolate: /\{\{\=(.+?)\}\}/g,
    evaluate: /\{\{(.+?)\}\}/g
  };
  var compiled = _.template($template);
  var rendered = compiled(json);

  //Insert rendered template
  $this.find('textarea').after(rendered);

  //Change preview class
  if (json.thumbnail_url == null){
    $this.find('.post-resource').addClass('no-preview');
  }

  // Fechar conteúdo embedded
  $this.find('.close').live('click', function(){
    $(this).parents('fieldset').find('textarea').data('last_url', "");
    $(this).parents('fieldset').find('.post-resource').slideUp(function(){
      $(this).remove();
    });
  });

  // Ações de navegação do thumbnail
  $this.find('.buttons-thumbnail span').live('click', function(){
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
  $this.find('input').live('click', function() {
    $(this).parents('fieldset').find("textarea").data('last_url', "");
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
