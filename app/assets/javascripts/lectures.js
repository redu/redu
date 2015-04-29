// Setando o tamanho do iframe do conteúdo da página simples
$.fn.setIframeHeight = function() {
  var $iframe = $("#page-iframe");

  $iframe.load(function() {
    $iframe.height($iframe.contents().height());
    $iframe.contents().each(function(i) {
      $(this).find("a").attr("target", "_blank");
    });
  });
};

$(function() {
  $(document).setIframeHeight();

  $(document).ajaxComplete(function() {
    $(document).setIframeHeight();
  });
});

// Redireciona para aula escolhida.
$(document).on("change", ".lectures-select", function() {
  window.location = $(this).children("option:selected").data("path");
});

// Acende/apaga as luzes.
$(document).on("click", ".lights", function() {
  $(".lights-fade").fadeToggle();
  $("body").toggleClass("lights-on");
});

// Abre a caixa de comentários no botão da barra lateral.
$(document).on("click", ".lecture-sidebar-comment", function() {
  $(".lecture-wall-wrapper .button-comment").trigger("click");
});

// Abre a caixa de pedir ajuda no botão da barra lateral.
$(document).on("click", ".lecture-sidebar-help", function() {
  $(".lecture-wall-wrapper .button-help").trigger("click");
})

// Abre a caixa de comentários.
$(document).on("click", ".lecture-wall-wrapper .button-comment", function() {
  var $button = $(this);
  var $action = $button.parent();
  var $wrapper = $button.closest(".lecture-wall-wrapper");
  var $actions = $wrapper.find(".lecture-wall-action");
  var $createStatus = $wrapper.find(".create-status");
  var $textArea = $createStatus.find("textarea");
  var $statusType = $createStatus.find('[name="status[type]"]');

  $actions.removeClass("open");
  $action.addClass("open");

  if (!$createStatus.data("open")) {
    $createStatus.slideDown(150, "swing");
    $createStatus.data("open", true);
  }

  $createStatus.removeClass("tab-right");
  $createStatus.addClass("tab-left");
  $textArea.attr("placeholder", "Comente nesta aula.");
  $statusType.val("Activity");
  $textArea.focus();
});

// Abre a caixa de pedir ajuda.
$(document).on("click", ".lecture-wall-wrapper .button-help", function() {
  var $button = $(this);
  var $action = $button.parent();
  var $wrapper = $button.closest(".lecture-wall-wrapper");
  var $actions = $wrapper.find(".lecture-wall-action");
  var $createStatus = $wrapper.find(".create-status");
  var $textArea = $createStatus.find("textarea");
  var $statusType = $createStatus.find('[name="status[type]"]');

  $actions.removeClass("open");
  $action.addClass("open");

  if (!$createStatus.data("open")) {
    $createStatus.slideDown(150, "swing");
    $createStatus.data("open", true);
  }

  $createStatus.removeClass("tab-left");
  $createStatus.addClass("tab-right");
  $textArea.attr("placeholder", "Peça ajuda nesta aula.");
  $statusType.val("Help");
  $textArea.focus();
});

// No cancelar, remove também a classe de aberto.
$(document).on("click", ".lecture-wall-wrapper .cancel", function() {
  var $wrapper = $(this).closest(".lecture-wall-wrapper");
  var $actions = $wrapper.find(".lecture-wall-action");
  var $createStatus = $wrapper.find(".create-status");

  $actions.removeClass("open");
  $createStatus.slideUp(150, "swing").data("open", false);
});