/* ========================================================================
 * Bootstrap: scrollspy.js v3.3.6
 * http://getbootstrap.com/javascript/#scrollspy
 * ========================================================================
 * Copyright 2011-2015 Twitter, Inc.
 * Licensed under MIT (https://github.com/twbs/bootstrap/blob/master/LICENSE)
 * ======================================================================== */



+function ($) {
  'use strict';

  // SCROLLSPY CLASS DEFINITION
  // ==========================

  function ScrollSpy(element, options) {
    this.$body          = $(document.body)
    this.$scrollElement = $(element).is(document.body) ? $(window) : $(element)
    this.options        = $.extend({}, ScrollSpy.DEFAULTS, options)
    this.selector       = (this.options.target || '') + ' ' + this.options.selector
    this.offsets        = []
    this.targets        = []
    this.activeTarget   = null
    this.scrollHeight   = 0

    this.$scrollElement.on('scroll.bs.scrollspy', $.proxy(this.process, this))
    this.refresh()
    this.process()
  }

  ScrollSpy.VERSION  = '3.3.6'

  ScrollSpy.DEFAULTS = {
    offset: 10,
    // Classe que indica estado ativado.
    activeClass: 'active',
    // Seletor dos alvos.
    selector: '.nav li > a',
    // Indica se a classe de estado ativado deve ser aplicada ao pai do seletor (true) ou no próprio seletor (false).
    applyActiveToParent: true
  }

  ScrollSpy.prototype.getScrollHeight = function () {
    return this.$scrollElement[0].scrollHeight || Math.max(this.$body[0].scrollHeight, document.documentElement.scrollHeight)
  }

  ScrollSpy.prototype.refresh = function () {
    var that          = this
    var offsetMethod  = 'offset'
    var offsetBase    = 0

    this.offsets      = []
    this.targets      = []
    this.scrollHeight = this.getScrollHeight()

    if (!$.isWindow(this.$scrollElement[0])) {
      offsetMethod = 'position'
      offsetBase   = this.$scrollElement.scrollTop()
    }

    this.$body
      .find(this.selector)
      .map(function () {
        var $el   = $(this)
        var href  = $el.data('target') || $el.attr('href')
        var $href = /^#./.test(href) && $(href)

        return ($href
          && $href.length
          && $href.is(':visible')
          && [[$href[offsetMethod]().top + offsetBase, href]]) || null
      })
      .sort(function (a, b) { return a[0] - b[0] })
      .each(function () {
        that.offsets.push(this[0])
        that.targets.push(this[1])
      })
  }

  ScrollSpy.prototype.process = function () {
    var scrollTop    = this.$scrollElement.scrollTop() + this.options.offset
    var scrollHeight = this.getScrollHeight()
    var maxScroll    = this.options.offset + scrollHeight - this.$scrollElement.height()
    var offsets      = this.offsets
    var targets      = this.targets
    var activeTarget = this.activeTarget
    var i

    if (this.scrollHeight != scrollHeight) {
      this.refresh()
    }

    if (scrollTop >= maxScroll) {
      return activeTarget != (i = targets[targets.length - 1]) && this.activate(i)
    }

    if (activeTarget && scrollTop < offsets[0]) {
      this.activeTarget = null
      return this.clear()
    }

    for (i = offsets.length; i--;) {
      activeTarget != targets[i]
        && scrollTop >= offsets[i]
        && (offsets[i + 1] === undefined || scrollTop < offsets[i + 1])
        && this.activate(targets[i])
    }
  }

  ScrollSpy.prototype.activate = function (target) {
    this.activeTarget = target

    this.clear()

    var selector = this.selector +
      '[data-target="' + target + '"],' +
      this.selector + '[href="' + target + '"]'


    var $active = $(selector)

    if (this.options.applyActiveToParent) {
      $active
        .parents('li')
        .addClass(this.options.activeClass)

      if ($active.parent('.dropdown-menu').length) {
        $active = $active
          .closest('li.dropdown')
          .addClass(this.options.activeClass)
      }
    } else {
      $active = $active.addClass(this.options.activeClass)
    }

    $active.trigger('activate.bs.scrollspy')
  }

  ScrollSpy.prototype.clear = function () {
    var $selector = $(this.selector);

    if (this.options.applyActiveToParent) {
      $selector = $selector
        .parentsUntil(this.options.target, '.' + this.options.activeClass)
    }

    $selector.removeClass(this.options.activeClass)
  }


  // SCROLLSPY PLUGIN DEFINITION
  // ===========================

  function Plugin(option) {
    return this.each(function () {
      var $this   = $(this)
      var data    = $this.data('bs.scrollspy')
      var options = typeof option == 'object' && option

      if (!data) $this.data('bs.scrollspy', (data = new ScrollSpy(this, options)))
      if (typeof option == 'string') data[option]()
    })
  }

  var old = $.fn.scrollspy

  $.fn.scrollspy             = Plugin
  $.fn.scrollspy.Constructor = ScrollSpy


  // SCROLLSPY NO CONFLICT
  // =====================

  $.fn.scrollspy.noConflict = function () {
    $.fn.scrollspy = old
    return this
  }


  // SCROLLSPY DATA-API
  // ==================

  $(window).on('load.bs.scrollspy.data-api', function () {
    $('[data-spy="scroll"]').each(function () {
      var $spy = $(this)
      Plugin.call($spy, $spy.data())
    })
  })

}(jQuery);



// Carrega a imagem da modal do tipo de aula quando ela é aberta.
$(document).on("shown", ".modal-multimedia", function(e) {
  var $modal = $(this);
  var $image = $modal.find("img.lazy");

  if (!$image.data("loaded")) {
    $image.attr("src", $image.data("original"));
    $image.data("loaded", true);
  }
});

// Deixa o menu dos filtros fixos
$(function() {

  var $win = $(window);

  var $landingFilters = $(".landing-filters");

  var landingFiltersFixed = 0;
  var landingFiltersTop = $landingFilters.length && $landingFilters.offset().top;

  var scrolllandingFilters = function() {
    var _, scrollTop = $win.scrollTop();
    if (scrollTop >= landingFiltersTop && !landingFiltersFixed) {
      landingFiltersFixed = 1;
      $landingFilters.addClass("landing-filters-fixed");
    }
    else if (scrollTop <= landingFiltersTop && landingFiltersFixed) {
      landingFiltersFixed = 0;
      $landingFilters.removeClass("landing-filters-fixed");
    }
  }

  // Faz com que o menu dos filtros fique com top e fixo, quando o usuário estiver logado.
  scrolllandingFilters();

  $win.bind("scroll", scrolllandingFilters);

  $(".nav-global").each(function() {
    $landingFilters.css('marginTop', '42px')
  });

  // Faz com que os títulos das navegações apareçam
  $(".landing-scroll").click( function(event) {
    event.preventDefault();
    var offset = $($(this).attr('href').replace('/', '')).offset().top;
    var height = 120;

    if ($landingFilters.css('top') === "0px") {
      height = 60;
    }

    $('html, body').animate({scrollTop: (offset - height)}, 500);
  });

  $('.facebook-sign-in-button, .header-sign-in-recover').click( function(e) {
    e.stopPropagation();
  });

  // Abre as modais que devem ser abertas após carregar a página
  $("#modal-sign-up.open-me").modal("show");

  // Ativa o Scrollspy do Twitter.
  (function() {
    var filtersScrollspyTarget = '.js-filters-scrollspy';
    var filtersScrollspyOffset = $(filtersScrollspyTarget).outerHeight();

    $(document.body).scrollspy({
      target: filtersScrollspyTarget,
      offset: filtersScrollspyOffset,
      activeClass: 'filter-active',
      selector: '.filter',
      applyActiveToParent: false
    });
  })();
});
