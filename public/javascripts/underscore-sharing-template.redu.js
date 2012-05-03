$.fn.renderTemplate = function(json) {
  $this = $(this);

  //Preview box
  $this.parents('fieldset').find('.post-resource').remove();

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
  $(rendered).insertAfter($this);

  //Change preview class
  if (json.thumbnail_url == null){
    $this.parents('fieldset').find('.post-resource').addClass('no-preview');
  }
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
