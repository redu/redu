// Retorna uma string com as classes de ícones identificadas.
//
// Dado uma string "classes", encontra todas as classes de ícones nela.
var findIconClasses = function(classes) {
  var iconClasses = [];

  classes = classes.split(' ');
  $.each(classes, function(index, value) {
    if (value.indexOf('icon-') !== -1) {
      iconClasses.push(value);
    }
  });

  return iconClasses.join(' ');
};

!(function($) {

  "use strict";

  var methods = {

    // Encontra o label correspondente de um checkbox/radio.
    findLabel: function($control) {
      // Primeiro tenta o label que encapsula o controle.
      var $label = $control.closest('label')
        , controlId = $control.attr('id')

      // Depois tenta achar o label se ele estiver ligado por controle[id] e label[for].
      if (typeof controlId !== 'undefined') {
        var $possibleLabel = $('label[for="' + controlId + '"]')

        if ($possibleLabel.length === 1) {
          $label = $possibleLabel
        }
      }

      return $label
    },

    init: function() {}
  }

  $.fn.reduForm = function(method) {
    if (methods[method]) {
      return methods[method].apply(this, Array.prototype.slice.call(arguments, 1))
    } else if (typeof method === "object" || !method) {
      return methods.init.apply(this, arguments)
    } else {
      $.error("O método " + method + " não existe em jQuery.reduForm")
    }
  }

}) (window.jQuery)

$(function() {
  // Comportamento de escurer texto do checkbox/radio selecionado.

  var reduFormRadioCheckboxSettings = {
    // Classe adicionada quando o controle está marcado.
    controlCheckedClass: 'control-checked'
  }

  $(document).on('change', 'input:radio, input:checkbox', function(e) {
    var $control = $(this)
      , $label = $.fn.reduForm('findLabel', $control)

    if ($label.length > 0) {
      $label.toggleClass(reduFormRadioCheckboxSettings.controlCheckedClass)

      // Se for um radio.
      if ($control.is('input:radio')) {
        // Procura o label dos outros radios para remover a classe.
        var $form = $control.closest('form')
          , controlName = $control.attr('name')
          , $otherControls = $form.find('[name="' + controlName + '"]:radio').filter(function(index) {
              return this !== $control[0]
            })

        $otherControls.each(function() {
          var $control = $(this)
            , $label = $.fn.reduForm('findLabel', $control)

          $label.removeClass(reduFormRadioCheckboxSettings.controlCheckedClass)
        })
      }
    }
  })

  // Caso de refresh da página o checkbox/radio marcado.
  $('input:radio, input:checkbox').each(function() {
    var $control = $(this)
      , $label = $.fn.reduForm('findLabel', $control)

    if ($control.prop('checked')) {
      $label.addClass(reduFormRadioCheckboxSettings.controlCheckedClass)
    }
  })


  // No elemento de opção com texto e formulários de busca, quando o campo ou
  // área de texto estiverem selecionados, mudar a cor da borda e os ícones dos
  // botões de cinza para azul. O inverso acontece quando deselecionado.
  var colorBlue2 = '#73C3E6'
    , selectorControlArea = '.control-area.area-infix'
    , classesFixedArea = '.area-suffix, .form-search-filters-button'
    , classIcon = "[class^='icon-'],[class*=' icon-']"
  $(document)
    .on('focusin', selectorControlArea, function(e) {
      var $fixedAreas = $(this).parent().find(classesFixedArea)
        , $buttonsIcons = $fixedAreas.find(classIcon)
      // Troca a cor da borda.
      $fixedAreas.css('border-color', colorBlue2);

      // Troca a cor do ícone.
      $buttonsIcons.each(function() {
        var $button = $(this)
          , iconClasses = findIconClasses($button.attr('class'))
        $button
          .removeClass(iconClasses)
          .addClass(iconClasses.replace('gray', 'lightblue'))
      })
    })
    .on('focusout', selectorControlArea, function(e) {
      var $fixedAreas = $(this).parent().find(classesFixedArea)
        , $buttonsIcons = $fixedAreas.find(classIcon)
      // Troca a cor da borda.
      $fixedAreas.css('border-color', '');

      // Troca a cor do ícone.
      $buttonsIcons.each(function() {
        var $button = $(this)
          , iconClasses = findIconClasses($button.attr('class'))
        $button
          .removeClass(iconClasses)
          .addClass(iconClasses.replace('lightblue', 'gray'))
      })
    })
    .on('change', '.form-search-filters input:radio', function(e) {
      var $radio = $(this)
        , $legendIcon = $radio.siblings('.legend')
        , newIconClass = findIconClasses($legendIcon.attr('class'))
        , $buttonIcon = $radio.closest('.form-search-filters').find('.form-search-filters-button .control-search-icon')
        , currentIconClass = findIconClasses($buttonIcon.attr('class'))

      $buttonIcon.removeClass(currentIconClass).addClass(newIconClass.replace('-before', ''))
    })
})


!function ($) {

  "use strict"; // jshint ;_;


 /* DEFINIÇÃO DE CLASSE DO CAMPO DE BUSCA.
  * ============================== */

  var SearchField = function (element, options) {
    this.$element = $(element)
    this.options = $.extend({}, $.fn.searchField.defaults, options)
  }

  SearchField.prototype.expand = function () {
    var $target = $(this.$element.data('toggle'))
      , isFocused = this.$element.data('isFocused')

    if (!isFocused) {
      this.$element.parent().animate({ width: '+=' + this.options.increment }, 'fast');
      $target.hide()
      this.$element.data('isFocused', true)
    }
  }

  SearchField.prototype.collapse = function () {
    var $target = $(this.$element.data('toggle'))
      , isFocused = this.$element.data('isFocused')

    if (isFocused) {
      this.$element.parent().animate({ width: '-=' + this.options.increment }, 'fast');
      $target.show()
      this.$element.data('isFocused', false)
    }
  }


 /* DEFINIÇÃO DO PLUGIN DO CAMPO DE BUSCA.
  * ======================== */

  $.fn.searchField = function (option) {
    return this.each(function () {
      var $this = $(this)
        , data = $this.data('searchField')
        , options = typeof option == 'object' && option
      if (!data) $this.data('searchField', (data = new SearchField(this, options)))
      if (option == 'expand') data.expand()
      else if (option == 'collapse') data.collapse()
    })
  }

  $.fn.searchField.defaults = {
    increment: 100
  }

  $.fn.searchField.Constructor = SearchField


 /* DATA-API DO CAMPO DE BUSCA.
  * =============== */

  $(function () {
    $('body')
      .on('focusin', '.form-search-expandable', function ( e ) {
        var $searchField = $(e.target)

        if ($searchField.hasClass('control-area')) {
          $searchField.searchField('expand')
        }
      })
      .on('focusout', '.form-search-expandable', function ( e ) {
        var $searchField = $(e.target)

        if ($searchField.hasClass('control-area')) {
          $searchField.searchField('collapse')
        }
      })
  })

}(window.jQuery);