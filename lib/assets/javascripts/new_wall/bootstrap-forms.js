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