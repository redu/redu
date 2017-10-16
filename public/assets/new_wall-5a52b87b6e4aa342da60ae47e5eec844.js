// Copiado do bootstrap sem modificações.


// Retorna uma string com as classes de ícones identificadas.
//
// Dado uma string "classes", encontra todas as classes de ícones nela.
var findIconClasses = function(classes) {
  var iconClasses = [];

  if (classes) {
    classes = classes.split(' ');
    $.each(classes, function(index, value) {
      if (value.indexOf('icon-') !== -1) {
        iconClasses.push(value);
      }
    });
  }

  return iconClasses.join(' ');
};
// Copiado do bootstrap com modificação no caminho dos assets para os spinners (L#20).


/*global findIconClasses */


!(function($) {

  'use strict';

  var settings = {
    buttonDefault: 'button-default'
  , buttonPrimary: 'button-primary'
  , buttonDanger: 'button-danger'
  , buttonSuccess: 'button-success'
  , buttonDisabled: 'button-disabled'
  , linkSecondary: 'link-secondary'
  , spinnerHorizontalBlue: 'spinner-horizontal-blue'
  , spinnerCircularGray: 'spinner-circular-gray'
  , spinnerCircularBlue: 'spinner-circular-blue'
  , imgPath: '/assets/'
  , spinnerCircularBlueGif: 'spinner-blue.gif'
  , spinnerCircularGrayGif: 'spinner-grey.gif'
  , spinnerCSS: {
      'display': 'inline-block'
    , 'vertical-align': 'middle'
    }
  }

  var methods = {
    // Verifica se o elemento tem alguma classe de botão.
    hasButtonClass: function($element) {
      return ($element.hasClass(settings.buttonDefault)
            || $element.hasClass(settings.buttonPrimary)
            || $element.hasClass(settings.buttonDanger)
            || $element.hasClass(settings.buttonSuccess))
    }

    // Chamado antes da requesição AJAX.
  , ajaxBefore: function(options) {
      settings = $.extend(settings, options)

      var $this = $(this)

      // Se for um formulário.
      if ($this.is('form')) {
        var $submit = $this.find('input:submit, button[type="submit"]')
          , spinnerClass = settings.spinnerCircularGray
          , submitIconClasses = findIconClasses($submit.attr('class'))
          , submitWidth = $submit.outerWidth()
          , submitHeight = $submit.outerHeight()

        if ($submit.hasClass(settings.buttonDefault)) {
          spinnerClass = settings.spinnerCircularBlue
        }

        $submit
          .addClass(spinnerClass)
          .prop('disabled', true)
          .data('spinnerClass', spinnerClass)
          .data('content', $submit.val())
          .data('class', submitIconClasses)
          .removeClass(submitIconClasses)
          .css({ 'width': submitWidth, 'height': submitHeight })
          .val('')
      }

      // Se for um botão.
      if (methods.hasButtonClass($this)) {
        // Botão padrão usa o spinner azul e os outros cinza.
        var spinnerImg = settings.imgPath
        if ($this.hasClass(settings.buttonDefault)) {
          spinnerImg += settings.spinnerCircularBlueGif
        } else {
          spinnerImg += settings.spinnerCircularGrayGif
        }

        var content = $this.html()
          , width = $this.width()
          , height = $this.height()
          , iconClasses = findIconClasses($this.attr('class'))
          , $spinner = $(document.createElement('img')).attr('src', spinnerImg).css(settings.spinnerCSS)

        $this
          .addClass(settings.buttonDisabled)
          .removeClass(iconClasses)
          .data('content', content)
          .data('class', iconClasses)
          .html($spinner)
          .css({'width': width, 'height': height})
      } else if ($this.is('a')) {
        // Link secundário usa o spinner horizontal azul, o normal usa o circular cinza.
        var linkSpinnerClass = settings.spinnerCircularGray
        if ($this.hasClass(settings.linkSecondary)) {
          linkSpinnerClass = settings.spinnerHorizontalBlue
        }

        $this.data('spinnerClass', linkSpinnerClass)
        $this.addClass(linkSpinnerClass)
      }
    }

    // Chamado depois da requisição AJAX.
  , ajaxComplete: function(options) {
      settings = $.extend(settings, options)

      var $this = $(this)

      if ($this.is('form')) {
        var $submit = $this.find('input:submit, button[type="submit"]')

        $submit
          .removeClass($submit.data('spinnerClass'))
          .addClass($submit.data('class'))
          .prop('disabled', false)
          .val($submit.data('content'))
      }

      // Se for um botão.
      if (methods.hasButtonClass($this)) {
        $this
          .removeClass(settings.buttonDisabled)
          .addClass($this.data('class'))
          .html($this.data('content'))
      } else if ($this.is('a')) {
        $this.removeClass($this.data('spinnerClass'))
      }
    }
  }

  $.fn.reduSpinners = function(method) {
    if (methods[method]) {
      return methods[method].apply(this, Array.prototype.slice.call(arguments, 1))
    } else if (typeof method === 'object' || !method) {
      return methods.init.apply(this, arguments)
    } else {
      $.error('O método ' + method + ' não existe em jQuery.reduSpinners')
    }
  }

}) (window.jQuery)

$(function() {
  $(document)
    .on('ajax:beforeSend', '[data-remote="true"]', function(xhr, settings) {
      $(this).reduSpinners('ajaxBefore')
    })
    .on('ajax:complete', '[data-remote="true"]', function(xhr, status) {
      $(this).reduSpinners('ajaxComplete')
    })
})
;
// Copiado do bootstrap com modificações para conter somente os métodos countChars
// e resizeByRows aplicados a textareas.


!(function($) {

  "use strict";

  var methods = {

    // Ajusta a altura do textarea de acordo com seu atributo rows.
    resizeByRows: function(options) {
      return this.each(function() {
        var $textarea = $(this)
          , rowsTemp = $textarea.attr('rows')
          , rows = (rowsTemp !== '' ? parseInt(rowsTemp, 10) : 0)

        if (rows !== 0) {
          var pxToInt = function(value) {
            if (typeof value !== 'undefined') {
              return parseInt(value.replace('px', ''), 10)
            } else {
              return 0;
            }
          }

          var lineHeight = pxToInt($textarea.css('line-height'))
            , borderTop = pxToInt($textarea.css('border-top-width'))
            , borderBottom = pxToInt($textarea.css('border-bottom-width'))
            , marginTop = pxToInt($textarea.css('margin-top'))
            , marginBottom = pxToInt($textarea.css('margin-bottom'))
            , paddingTop = pxToInt($textarea.css('padding-top'))
            , paddingBottom = pxToInt($textarea.css('padding-bottom'))

          $textarea.height((rows * lineHeight) + borderTop + borderBottom + marginTop + marginBottom + paddingTop + paddingBottom)
        }
      })
    },

    init: function() {}
  }

  $.fn.reduTextArea = function(method) {
    if (methods[method]) {
      return methods[method].apply(this, Array.prototype.slice.call(arguments, 1))
    } else if (typeof method === "object" || !method) {
      return methods.init.apply(this, arguments)
    } else {
      $.error("O método " + method + " não existe em jQuery.reduTextArea")
    }
  }

}) (window.jQuery)

$(function() {
  // Contador de caracteres.
  var characterCounterSelector = 'textarea[maxlength]'
    , remainingCharsText = function(maxLength, charCount, control) {
      var charDifference = maxLength - charCount

      if (charDifference <= 0) {
        if (control.is('textarea')) {
          // No IE o maxlength não funciona para as áreas de texto.
          control.text(control.text().substring(0, maxLength))
        }

        return 'Nenhum caracter restante.'
      } else if (charDifference === 1) {
        return '1 caracter restante.'
      } else {
        return charDifference + ' caracteres restantes.'
      }
    }

  $(document)
    .on("focusin", characterCounterSelector, function() {
      var $control = $(this)
        , maxLength = $control.attr("maxlength")
        , $counter = $('<span class="character-counter legend"></span>')

      $counter.text(remainingCharsText(maxLength, $control.val().length, $control))
      $counter.insertAfter($control)
    })
    .on("focusout", characterCounterSelector, function() {
      var $control = $(this)
        , $counter = $control.next()

      if ($counter.hasClass("character-counter")) {
        $counter.remove()
      }
    })
    .on("keyup", characterCounterSelector, function() {
      var $control = $(this)
        , maxLength = $control.attr("maxlength")
        , $counter = $control.next()

      if ($counter.hasClass("character-counter")) {
        $counter.text(remainingCharsText(maxLength, $control.val().length, $control))
      }
    })

  $('textarea[rows]').reduTextArea('resizeByRows')
})
;
// Copiado do bootstrap sem modificações.


// Exibe formulário para criação de status.
$(document).on("focusin", ".status-tab textarea", function() {
  var $textArea = $(this);

  if (!$textArea.data("open")) {
    $textArea
      .animate({ height: "122px" }, 150, "swing", function() {
        var $buttons = $textArea.closest(".status-tab").find(".status-buttons");

        $buttons.slideDown(150, "swing");
      })
      .data("open", true);
  }
});

// Cancela a criação de status.
$(document).on("click", ".create-status .cancel", function() {
  var $cancelButton = $(this);
  var $createStatus = $cancelButton.closest(".create-status");
  var $statusButtons = $createStatus.find(".status-buttons");
  var $preview = $createStatus.find(".post-resource");
  var $textArea = $createStatus.find("textarea");

  $statusButtons.slideUp(150, "swing", function() {
    $textArea
      .animate({ height: 32 }, 150, "swing", function() {
        $preview.slideUp(150, "swing", function() {
          $preview.remove();
        });
      })
      .data("open", false);
  });
});

// Exibe formulário para criação de respostas.
$(document).on("click", ".status .reply-status .link-secondary", function() {
  var $subjectContent = $(this).closest(".subject-content");
  var $createResponse = $subjectContent.find(".create-response");
  var $textArea = $createResponse.find("textarea");

  $createResponse.slideToggle(150, "swing");
  $textArea.focus();
});

// Esconde formulário para criação de respostas.
$(document).on("click", ".status .cancel", function() {
  var $cancelButton = $(this);
  var $createStatus = $cancelButton.closest(".create-response");
  var $preview = $createStatus.find(".post-resource");

  $createStatus.slideUp(150, "swing", function() {
    $preview.remove();
  });
});

// Expande/minimiza as respostas dos comentários.
$(document).on("click", ".status .see-more", function() {
  var $link = $(this);
  var $status = $link.closest(".status");
  var $lastResponses = $status.find(".last-responses");
  var $responses = $status.find(".responses").children().filter(":not(.show-responses)");
  var totalResponses = $responses.length;

  if (!$link.data("open")) {
    // Mostra as respostas que estavam escondidas.
    $responses.filter(":hidden").slideDown(150, "swing");
    $link.html("Esconder as primeiras respostas")
    $lastResponses.html("Visualizando todas as respostas...");
    $link.data("open", true);
  } else {
    // Deixa somente as 3 últimas visíveis.
    $responses.filter(":lt(" + (totalResponses - 3) + ")").slideUp(150, "swing");
    $link.html("Mostrar todas as " + totalResponses + " respostas");
    $lastResponses.html("Visualizando as últimas respostas...");
    $link.data("open", false);
  }
});

// Expande/minimiza os membros.
$(document).on("click", ".status-list .see-all", function() {
  var $link = $(this);
  var $groupingElements = $link.closest(".status").find(".grouping-elements");

  if (!$link.data("open")) {
    $groupingElements.animate({ height: $groupingElements[0].scrollHeight }, 150, "swing");
    $link
      .html("- Esconder todos")
      .data("open", true);
  } else {
    $groupingElements.animate({ height: 40 }, 150, "swing");
    $link
      .html("+ Ver todos")
      .data("open", false);
  }
});

// Agrupa as respostas.
$.fn.groupResponses = function(opts) {
  return this.each(function() {
    var options = {
      maxResponses : 3
    }
    $.extend(options, opts)
    var $this = $(this);
    var $responses = $this.children(":not(.show-responses)");

    if ($responses.length > options.maxResponses) {
      $responses.filter(":lt(" + ($responses.length - options.maxResponses) + ")").slideUp(150, "swing");
      $(this).find(".show-responses").show();
     } else {
      $this.find(".show-responses").hide();
      $responses.first().find("hr").hide();
    }
  });
}

// Conta a quantidade de respostas de um status e atualiza a legenda.
$.fn.countComments = function() {
  return this.each(function() {
    var $responses = $(this);
    var quantity = $responses.find(".response").length;
    var $seeMore = $responses.find(".see-more");

    $seeMore.html("Mostrar todas as " + quantity + " respostas");
  });
};

$(function() {
  $(".responses").groupResponses();
});

$(document).ajaxComplete(function() {
  $(".responses").groupResponses();
});
// JavaScripts necessários para o funcionamento do novo mural nas páginas sem bootstrap.
//
// TODO: remover quando a página incluir o bootstrap completo.
//




;
