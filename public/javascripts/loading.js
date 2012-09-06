(function(){
  // Mensagem "Carregando..."
  $("body").bind('start.pjax', function() {
    $('#loading-message').show();
  });
  $("body").bind('end.pjax', function() {
    $('#loading-message').hide();
  });
})();
