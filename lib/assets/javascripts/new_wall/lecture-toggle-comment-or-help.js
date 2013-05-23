// Copiado e adaptado dos botões de comentar e escrever resenha do portal de Aplicativos.


$(function() {
  // Realiza o comportamento dos botões de comentar e pedir ajuda.
  var openClass = "open";
  var buttonCommentClass = "button-comment";
  var buttonReviewClass = "button-help";
  var createResponseCommentClass = "tab-left";
  var createResponseReviewClass = "tab-right";
  var containerClass = "reply-buttons";

  $.fn.replyBehavior = function(options) {
    var settings = $.extend({}, options);

    return this.each(function() {
      $(document).on("click", "." + settings.buttonClass, function(e) {
        e.preventDefault();
        var $this = $(this);
        var $container = $this.parents("." + settings.containerClass);
        var $createResponse = $container.find("." + settings.createResponseClass);
        var $listItem = $container.find("." + settings.buttonClass).parent();

        // Se o botão está ativo e for clicado, esconde a área de texto.
        if ($listItem.hasClass(settings.openClass)) {
          $createResponse.slideUp(150, "swing");

        } else {
          // Esconde a área de texto do outro botão.
          $container.find("." + settings.otherButtonClass).parent().removeClass(settings.openClass);
          $container.find("." + settings.otherResponseClass).slideUp(150, "swing");
          // Mostra a área de texto do botão clicado.
          $createResponse.slideDown(150, "swing");
          $createResponse.find("textarea").focus();
        }

        $listItem.toggleClass(settings.openClass);
      });
    });
  };

  // Adiciona o comportamento para o botão de comentário comum.
  $("." + buttonCommentClass).replyBehavior({
    buttonClass: buttonCommentClass,
    createResponseClass: createResponseCommentClass,
    otherButtonClass: buttonReviewClass,
    otherResponseClass: createResponseReviewClass,
    openClass: openClass,
    containerClass: containerClass
  });

  // Adiciona o comportamento para o botão de pedir ajuda.
  $("." + buttonReviewClass).replyBehavior({
    buttonClass: buttonReviewClass,
    createResponseClass: createResponseReviewClass,
    otherButtonClass: buttonCommentClass,
    otherResponseClass: createResponseCommentClass,
    openClass: openClass,
    containerClass: containerClass
  });

  // No cancelar, remove também a classe de aberto.
  $(document).on("click", "." + containerClass + " .cancel", function(e) {
    $("." + buttonReviewClass + ", ." + buttonCommentClass).parent().removeClass(openClass);
  });
});