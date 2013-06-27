/*
  Comportamento de mostrar/esconder o diagrama de
  "O que são Ambientes de Aprendizagem?" na tela de "Ambientes que Participo".
*/

$(function() {
  var classes = {
    link: ".my-environments-explaination-link",
    wrapper: ".my-environments-explaination-wrapper",
    close: ".my-environments-explaination-close"
  };

  // Abre diagrama ao clicar no link.
  $(document).on("click", classes.link, function() {
    var $link = $(this);
    var $diagram = $(classes.wrapper);

    $link.slideUp(150, "swing");
    $diagram.slideDown(150, "swing");
  });

  // Fecha diagrama ao clicar no "x".
  $(document).on("click", classes.close, function() {
    var $diagram = $(classes.wrapper);
    var $link = $(classes.link);

    $diagram.slideUp(150, "swing");
    $link.slideDown(150, "swing");
  });
});