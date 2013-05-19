/* Copiado de application.js para o formulário de criar status funcionado com o novo layout */

$(function() {
  // Efeitos do form de status
  $(".inform-my-status textarea").live("focus", function(e){
      $(this).parents("form").find(".status-buttons, .char-limit").fadeIn();
  });
  $(".inform-my-status .status-buttons .cancel").live("click", function(){
      $(this).parents("form").find(".status-buttons, .char-limit").fadeOut();
  });

  // Aumentar form de criação de Status
  $(".status-buttons, .char-limit", ".inform-my-status").hide();
});

/* Limita a quantidade de caracteres de um campo */
function limitChars(textclass, limit, infodiv){
  var text = $('.' + textclass).val();
  var textlength = text.length;
  if (textlength > limit) {
    $('.' + textclass).val(text.substr(0, limit));
    return false;
  } else {
    $('.' + infodiv).html(limit - textlength);
    return true;
  }
}