jQuery(function(){
  // Permite ao usuário compartilhar recursos embutidos em suas postagens
  $.refreshEmbeddedSharing = function() {
    $('.status-tab').enableEmbedding();
  }

  $(document).ready(function(){
    $(document).ajaxComplete(function(){
      $.refreshEmbeddedSharing();
    });

    $.refreshEmbeddedSharing();
  });
});
