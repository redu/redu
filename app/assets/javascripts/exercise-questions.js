!function ($) {
  var config = {
    formClass: ".exercise-form",
    radioClass: ".exercise-choice-radio",
    loadingMessageId: "#loading-message",
    currentQuestionClass: ".exercise-question-navigation-item-current",
    answeredQuestionClass: "exercise-question-navigation-item-answered"
  };
  config.disableOnSaveClasses = ".exercise-question-button, .exercise-question-navigation a, " + config.radioClass;

  // Evita que links funcionem enquanto desabilitados.
  $(document).on("click", config.formClass + ' [disabled="disabled"]', function(e) {
    e.preventDefault();
  });

  // Mostra/esconde mensagem de carregado e habilita/desabilita os links.
  $(document)
    .on("ajax:before", config.formClass, function() {
      $(this).find(config.disableOnSaveClasses).attr("disabled", "disabled");
      $(config.loadingMessageId).fadeIn(150, "swing");
    })
    .on("ajax:complete", config.formClass, function() {
      $(this).find(config.disableOnSaveClasses).removeAttr("disabled", "disabled");
      $(config.loadingMessageId).fadeOut(150, "swing");
    })
    .on("ajax:success", config.formClass, function() {
      $(this).find(config.currentQuestionClass).addClass(config.answeredQuestionClass);
    });

  // Radio buttons salvam automaticamente as questões, via AJAX.
  $(document).on("change", config.formClass + " " + config.radioClass, function() {
    $(this).closest(config.formClass).submit();
  });
}(window.jQuery);