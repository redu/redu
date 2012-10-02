(function(){
  // Mensagem "Carregando..."
  $("#pjax-container").bind('start.pjax', function() {
    $('#loading-message').show();
  });
  $("#pjax-container").bind('end.pjax', function() {
    $('#loading-message').hide();
  });
})();
