!function ($) {

  "use strict"; // jshint ;_;


 /* DEFINIÇÃO DE CLASSE DO CAMPO DE BUSCA.
  * ============================== */

  var SearchField = function (element, options) {
    this.$element = $(element)
    this.options = $.extend({}, $.fn.searchField.defaults, options)
  }

  SearchField.prototype.expand = function () {
    var $target = $(this.$element.data("toggle"))
      , isFocused = this.$element.data("isFocused")

    if (!isFocused) {
      $target.hide()

      this.$element
        .data("isFocused", true)
        .closest("." + this.options.classes.formSearchExpandable)
        .animate({ width: "+=" + this.options.increment }, 150)
    }
  }

  SearchField.prototype.collapse = function () {
    var $target = $(this.$element.data("toggle"))
      , isFocused = this.$element.data("isFocused")

    if (isFocused) {
      $target.show()

      this.$element
        .data("isFocused", false)
        .closest("." + this.options.classes.formSearchExpandable)
        .animate({ width: "-=" + this.options.increment }, 150)
    }
  }


 /* DEFINIÇÃO DO PLUGIN DO CAMPO DE BUSCA.
  * ======================== */

  $.fn.searchField = function (option) {
    return this.each(function () {
      var $this = $(this)
        , data = $this.data("searchField")
        , options = typeof option == "object" && option
      if (!data) $this.data("searchField", (data = new SearchField(this, options)))
      if (option == "expand") data.expand()
      else if (option == "collapse") data.collapse()
    })
  }

  $.fn.searchField.defaults = {
    increment: 100
  , classes: {
      // Padrão a todo formulário de busca.
      formSearch: "form-search"
      // Formulário de busca que expande/contrai.
    , formSearchExpandable: "form-search-expandable"
      // Formulário de busca com dropdown de filtros.
    , formSearchFilters: "form-search-filters"
      // Campo de texto onde o termo de busca é digitado.
    , inputField: "control-area"
    }
  }

  $.fn.searchField.Constructor = SearchField


 /* DATA-API DO CAMPO DE BUSCA.
  * =============== */

  $(function () {
    var formSearchExpandableInputSelector = "." + $.fn.searchField.defaults.classes.formSearchExpandable + " ." + $.fn.searchField.defaults.classes.inputField
      , formSearchFiltersInputSelector = "." + $.fn.searchField.defaults.classes.formSearchFilters + " ." + $.fn.searchField.defaults.classes.inputField

    $(document)
      .on("focusin", formSearchExpandableInputSelector, function (e) {
        $(this).searchField("expand")
      })
      .on("focusout", formSearchExpandableInputSelector, function (e) {
        $(this).searchField("collapse")
      })
      .on("keypress", formSearchFiltersInputSelector, function(e) {
        // Submete o formulário quando o Enter é pressionado ao invés de abrir o dropdown.
        if (e.which == 13) {
          $(this).closest("." + $.fn.searchField.defaults.classes.formSearch).submit()
          return false
        }
      })
  })

}(window.jQuery);