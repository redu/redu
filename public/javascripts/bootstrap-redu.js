/* ===================================================
 * bootstrap-transition.js v2.0.4
 * http://twitter.github.com/bootstrap/javascript.html#transitions
 * ===================================================
 * Copyright 2012 Twitter, Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 * ========================================================== */


!function ($) {

  $(function () {

    "use strict"; // jshint ;_;


    /* CSS TRANSITION SUPPORT (http://www.modernizr.com/)
     * ======================================================= */

    $.support.transition = (function () {

      var transitionEnd = (function () {

        var el = document.createElement('bootstrap')
          , transEndEventNames = {
               'WebkitTransition' : 'webkitTransitionEnd'
            ,  'MozTransition'    : 'transitionend'
            ,  'OTransition'      : 'oTransitionEnd'
            ,  'msTransition'     : 'MSTransitionEnd'
            ,  'transition'       : 'transitionend'
            }
          , name

        for (name in transEndEventNames){
          if (el.style[name] !== undefined) {
            return transEndEventNames[name]
          }
        }

      }())

      return transitionEnd && {
        end: transitionEnd
      }

    })()

  })

}(window.jQuery);
/* ==========================================================
 * bootstrap-alert.js v2.0.4
 * http://twitter.github.com/bootstrap/javascript.html#alerts
 * ==========================================================
 * Copyright 2012 Twitter, Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 * ========================================================== */


!function ($) {

  "use strict"; // jshint ;_;


 /* ALERT CLASS DEFINITION
  * ====================== */

  var dismiss = '[data-dismiss="alert"]'
    , Alert = function (el) {
        $(el).on('click', dismiss, this.close)
      }

  Alert.prototype.close = function (e) {
    var $this = $(this)
      , selector = $this.attr('data-target')
      , $parent

    if (!selector) {
      selector = $this.attr('href')
      selector = selector && selector.replace(/.*(?=#[^\s]*$)/, '') //strip for ie7
    }

    $parent = $(selector)

    e && e.preventDefault()

    $parent.length || ($parent = $this.hasClass('alert') ? $this : $this.parent())

    $parent.trigger(e = $.Event('close'))

    if (e.isDefaultPrevented()) return

    $parent.removeClass('in')

    function removeElement() {
      $parent
        .trigger('closed')
        .remove()
    }

    $.support.transition && $parent.hasClass('fade') ?
      $parent.on($.support.transition.end, removeElement) :
      removeElement()
  }


 /* ALERT PLUGIN DEFINITION
  * ======================= */

  $.fn.alert = function (option) {
    return this.each(function () {
      var $this = $(this)
        , data = $this.data('alert')
      if (!data) $this.data('alert', (data = new Alert(this)))
      if (typeof option == 'string') data[option].call($this)
    })
  }

  $.fn.alert.Constructor = Alert


 /* ALERT DATA-API
  * ============== */

  $(function () {
    $('body').on('click.alert.data-api', dismiss, Alert.prototype.close)
  })

}(window.jQuery);
/* ============================================================
 * bootstrap-dropdown.js v2.1.1
 * http://twitter.github.com/bootstrap/javascript.html#dropdowns
 * ============================================================
 * Copyright 2012 Twitter, Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 * ============================================================ */


!function ($) {

  "use strict"; // jshint ;_;


 /* DROPDOWN CLASS DEFINITION
  * ========================= */

  var toggle = '[data-toggle=dropdown]'
    , Dropdown = function (element) {
        var $el = $(element).on('click.dropdown.data-api', this.toggle)
        $('html').on('click.dropdown.data-api', function () {
          $el.parent().removeClass('open')
        })
      }

  Dropdown.prototype = {

    constructor: Dropdown

  , toggle: function (e) {
      var $this = $(this)
        , $parent
        , isActive

      if ($this.is('.disabled, :disabled')) return

      $parent = getParent($this)

      isActive = $parent.hasClass('open')

      clearMenus()

      if (!isActive) {
        $parent.toggleClass('open')
        $this.focus()
      }

      return false
    }

  , keydown: function (e) {
      var $this
        , $items
        , $active
        , $parent
        , isActive
        , index

      if (!/(38|40|27)/.test(e.keyCode)) return

      $this = $(this)

      e.preventDefault()
      e.stopPropagation()

      if ($this.is('.disabled, :disabled')) return

      $parent = getParent($this)

      isActive = $parent.hasClass('open')

      if (!isActive || (isActive && e.keyCode == 27)) return $this.click()

      $items = $('[role=menu] li:not(.divider) a', $parent)

      if (!$items.length) return

      index = $items.index($items.filter(':focus'))

      if (e.keyCode == 38 && index > 0) index--                                        // up
      if (e.keyCode == 40 && index < $items.length - 1) index++                        // down
      if (!~index) index = 0

      $items
        .eq(index)
        .focus()
    }

  }

  function clearMenus() {
    getParent($(toggle))
      .removeClass('open')
  }

  function getParent($this) {
    var selector = $this.attr('data-target')
      , $parent

    if (!selector) {
      selector = $this.attr('href')
      selector = selector && /#/.test(selector) && selector.replace(/.*(?=#[^\s]*$)/, '') //strip for ie7
    }

    $parent = $(selector)
    $parent.length || ($parent = $this.parent())

    return $parent
  }


  /* DROPDOWN PLUGIN DEFINITION
   * ========================== */

  $.fn.dropdown = function (option) {
    return this.each(function () {
      var $this = $(this)
        , data = $this.data('dropdown')
      if (!data) $this.data('dropdown', (data = new Dropdown(this)))
      if (typeof option == 'string') data[option].call($this)
    })
  }

  $.fn.dropdown.Constructor = Dropdown


  /* APPLY TO STANDARD DROPDOWN ELEMENTS
   * =================================== */

  $(function () {
    $('html')
      .on('click.dropdown.data-api touchstart.dropdown.data-api', clearMenus)
    $('body')
      .on('click.dropdown touchstart.dropdown.data-api', '.dropdown form', function (e) { e.stopPropagation() })
      .on('click.dropdown.data-api touchstart.dropdown.data-api'  , toggle, Dropdown.prototype.toggle)
      .on('keydown.dropdown.data-api touchstart.dropdown.data-api', toggle + ', [role=menu]' , Dropdown.prototype.keydown)
  })

}(window.jQuery);

/* =========================================================
 * bootstrap-modal.js v2.0.4
 * http://twitter.github.com/bootstrap/javascript.html#modals
 * =========================================================
 * Copyright 2012 Twitter, Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 * ========================================================= */


!function ($) {

  "use strict"; // jshint ;_;


 /* MODAL CLASS DEFINITION
  * ====================== */

  var Modal = function (content, options) {
    this.options = options
    this.$element = $(content)
      .delegate('[data-dismiss="modal"]', 'click.dismiss.modal', $.proxy(this.hide, this))
  }

  Modal.prototype = {

      constructor: Modal

    , toggle: function () {
        return this[!this.isShown ? 'show' : 'hide']()
      }

    , show: function () {
        var that = this
          , e = $.Event('show')

        this.$element.trigger(e)
        this.$element.trigger('fitContent.redu')

        if (this.isShown || e.isDefaultPrevented()) return

        $('body').addClass('modal-open')

        this.isShown = true

        escape.call(this)
        backdrop.call(this, function () {
          var transition = $.support.transition && that.$element.hasClass('fade')

          if (!that.$element.parent().length) {
            that.$element.appendTo(document.body) //don't move modals dom position
          }

          that.$element
            .show()

          if (transition) {
            that.$element[0].offsetWidth // force reflow
          }

          that.$element.addClass('in')

          transition ?
            that.$element.one($.support.transition.end, function () { that.$element.trigger('shown') }) :
            that.$element.trigger('shown')

        })
      }

    , hide: function (e) {
        e && e.preventDefault()

        var that = this

        e = $.Event('hide')

        this.$element.trigger(e)

        if (!this.isShown || e.isDefaultPrevented()) return

        this.isShown = false

        $('body').removeClass('modal-open')

        escape.call(this)

        this.$element.removeClass('in')

        $.support.transition && this.$element.hasClass('fade') ?
          hideWithTransition.call(this) :
          hideModal.call(this)
      }

  }


 /* MODAL PRIVATE METHODS
  * ===================== */

  function hideWithTransition() {
    var that = this
      , timeout = setTimeout(function () {
          that.$element.off($.support.transition.end)
          hideModal.call(that)
        }, 500)

    this.$element.one($.support.transition.end, function () {
      clearTimeout(timeout)
      hideModal.call(that)
    })
  }

  function hideModal(that) {
    this.$element
      .hide()
      .trigger('hidden')

    backdrop.call(this)
  }

  function backdrop(callback) {
    var that = this
      , animate = this.$element.hasClass('fade') ? 'fade' : ''

    if (this.isShown && this.options.backdrop) {
      var doAnimate = $.support.transition && animate

      this.$backdrop = $('<div class="modal-backdrop ' + animate + '" />')
        .appendTo(document.body)

      if (this.options.backdrop != 'static') {
        this.$backdrop.click($.proxy(this.hide, this))
      }

      if (doAnimate) this.$backdrop[0].offsetWidth // force reflow

      this.$backdrop.addClass('in')

      doAnimate ?
        this.$backdrop.one($.support.transition.end, callback) :
        callback()

    } else if (!this.isShown && this.$backdrop) {
      this.$backdrop.removeClass('in')

      $.support.transition && this.$element.hasClass('fade')?
        this.$backdrop.one($.support.transition.end, $.proxy(removeBackdrop, this)) :
        removeBackdrop.call(this)

    } else if (callback) {
      callback()
    }
  }

  function removeBackdrop() {
    this.$backdrop.remove()
    this.$backdrop = null
  }

  function escape() {
    var that = this
    if (this.isShown && this.options.keyboard) {
      $(document).on('keyup.dismiss.modal', function ( e ) {
        e.which == 27 && that.hide()
      })
    } else if (!this.isShown) {
      $(document).off('keyup.dismiss.modal')
    }
  }


 /* MODAL PLUGIN DEFINITION
  * ======================= */

  $.fn.modal = function (option) {
    return this.each(function () {
      var $this = $(this)
        , data = $this.data('modal')
        , options = $.extend({}, $.fn.modal.defaults, $this.data(), typeof option == 'object' && option)
      if (!data) $this.data('modal', (data = new Modal(this, options)))
      if (typeof option == 'string') data[option]()
      else if (options.show) data.show()
    })
  }

  $.fn.modal.defaults = {
      backdrop: true
    , keyboard: true
    , show: true
  }

  $.fn.modal.Constructor = Modal


 /* MODAL DATA-API
  * ============== */

  $(function () {
    $('body').on('click.modal.data-api', '[data-toggle="modal"]', function ( e ) {
      var $this = $(this), href
        , $target = $($this.attr('data-target') || (href = $this.attr('href')) && href.replace(/.*(?=#[^\s]+$)/, '')) //strip for ie7
        , option = $target.data('modal') ? 'toggle' : $.extend({}, $target.data(), $this.data())

      e.preventDefault()
      $target.modal(option)
    })
  })

}(window.jQuery);

/* ===========================================================
 * bootstrap-tooltip.js v2.0.4
 * http://twitter.github.com/bootstrap/javascript.html#tooltips
 * Inspired by the original jQuery.tipsy by Jason Frame
 * ===========================================================
 * Copyright 2012 Twitter, Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 * ========================================================== */


!function ($) {

  "use strict"; // jshint ;_;


 /* TOOLTIP PUBLIC CLASS DEFINITION
  * =============================== */

  var Tooltip = function (element, options) {
    this.init('tooltip', element, options)
  }

  Tooltip.prototype = {

    constructor: Tooltip

  , init: function (type, element, options) {
      var eventIn
        , eventOut

      this.type = type
      this.$element = $(element)
      this.options = this.getOptions(options)
      this.enabled = true

      if (this.options.trigger != 'manual') {
        eventIn  = this.options.trigger == 'hover' ? 'mouseenter' : 'focus'
        eventOut = this.options.trigger == 'hover' ? 'mouseleave' : 'blur'
        this.$element.on(eventIn, this.options.selector, $.proxy(this.enter, this))
        this.$element.on(eventOut, this.options.selector, $.proxy(this.leave, this))
      }

      this.options.selector ?
        (this._options = $.extend({}, this.options, { trigger: 'manual', selector: '' })) :
        this.fixTitle()
    }

  , getOptions: function (options) {
      options = $.extend({}, $.fn[this.type].defaults, options, this.$element.data())

      if (options.delay && typeof options.delay == 'number') {
        options.delay = {
          show: options.delay
        , hide: options.delay
        }
      }

      return options
    }

  , enter: function (e) {
      var self = $(e.currentTarget)[this.type](this._options).data(this.type)

      if (!self.options.delay || !self.options.delay.show) return self.show()

      clearTimeout(this.timeout)
      self.hoverState = 'in'
      this.timeout = setTimeout(function() {
        if (self.hoverState == 'in') self.show()
      }, self.options.delay.show)
    }

  , leave: function (e) {
      var self = $(e.currentTarget)[this.type](this._options).data(this.type)

      if (this.timeout) clearTimeout(this.timeout)
      if (!self.options.delay || !self.options.delay.hide) return self.hide()

      self.hoverState = 'out'
      this.timeout = setTimeout(function() {
        if (self.hoverState == 'out') self.hide()
      }, self.options.delay.hide)
    }

  , show: function () {
      var $tip
        , inside
        , pos
        , actualWidth
        , actualHeight
        , placement
        , tp

      if (this.hasContent() && this.enabled) {
        $tip = this.tip()
        this.setContent()

        if (this.options.animation) {
          $tip.addClass('fade')
        }

        placement = typeof this.options.placement == 'function' ?
          this.options.placement.call(this, $tip[0], this.$element[0]) :
          this.options.placement

        inside = /in/.test(placement)

        $tip
          .remove()
          .css({ top: 0, left: 0, display: 'block' })
          .appendTo(inside ? this.$element : document.body)

        pos = this.getPosition(inside)

        actualWidth = $tip[0].offsetWidth
        actualHeight = $tip[0].offsetHeight

        switch (inside ? placement.split(' ')[1] : placement) {
          case 'bottom':
            tp = {top: pos.top + pos.height, left: pos.left + pos.width / 2 - actualWidth / 2}
            // No caso especifico do popover2.
            if (this.$element.attr('data-original-title') === '' && this.$element.attr('rel') === 'popover') {
              tp = {top: pos.top + pos.height, left: pos.left + pos.width - actualWidth + 20}
              $tip.find('.arrow').css({ left: '92%' })
            }
            break
          case 'top':
            tp = {top: pos.top - actualHeight, left: pos.left + pos.width / 2 - actualWidth / 2}
            break
          case 'left':
            tp = {top: pos.top + pos.height / 2 - actualHeight / 2, left: pos.left - actualWidth}
            break
          case 'right':
            tp = {top: pos.top + pos.height / 2 - actualHeight / 2, left: pos.left + pos.width}
            break
        }

        $tip
          .css(tp)
          .addClass(placement)
          .addClass('in')
      }
    }

  , isHTML: function(text) {
      // html string detection logic adapted from jQuery
      return typeof text != 'string'
        || ( text.charAt(0) === "<"
          && text.charAt( text.length - 1 ) === ">"
          && text.length >= 3
        ) || /^(?:[^<]*<[\w\W]+>[^>]*$)/.exec(text)
    }

  , setContent: function () {
      var $tip = this.tip()
        , title = this.getTitle()

      $tip.find('.tooltip-inner')[this.isHTML(title) ? 'html' : 'text'](title)
      $tip.removeClass('fade in top bottom left right')
    }

  , hide: function () {
      var that = this
        , $tip = this.tip()

      $tip.removeClass('in')

      function removeWithAnimation() {
        var timeout = setTimeout(function () {
          $tip.off($.support.transition.end).remove()
        }, 500)

        $tip.one($.support.transition.end, function () {
          clearTimeout(timeout)
          $tip.remove()
        })
      }

      $.support.transition && this.$tip.hasClass('fade') ?
        removeWithAnimation() :
        $tip.remove()
    }

  , fixTitle: function () {
      var $e = this.$element
      if ($e.attr('title') || typeof($e.attr('data-original-title')) != 'string') {
        $e.attr('data-original-title', $e.attr('title') || '').removeAttr('title')
      }
    }

  , hasContent: function () {
      return this.getTitle()
    }

  , getPosition: function (inside) {
      return $.extend({}, (inside ? {top: 0, left: 0} : this.$element.offset()), {
        width: this.$element[0].offsetWidth
      , height: this.$element[0].offsetHeight
      })
    }

  , getTitle: function () {
      var title
        , $e = this.$element
        , o = this.options

      title = $e.attr('data-original-title')
        || (typeof o.title == 'function' ? o.title.call($e[0]) :  o.title)

      return title
    }

  , tip: function () {
      return this.$tip = this.$tip || $(this.options.template)
    }

  , validate: function () {
      if (!this.$element[0].parentNode) {
        this.hide()
        this.$element = null
        this.options = null
      }
    }

  , enable: function () {
      this.enabled = true
    }

  , disable: function () {
      this.enabled = false
    }

  , toggleEnabled: function () {
      this.enabled = !this.enabled
    }

  , toggle: function () {
      this[this.tip().hasClass('in') ? 'hide' : 'show']()
    }

  }


 /* TOOLTIP PLUGIN DEFINITION
  * ========================= */

  $.fn.tooltip = function ( option ) {
    return this.each(function () {
      var $this = $(this)
        , data = $this.data('tooltip')
        , options = typeof option == 'object' && option
      if (!data) $this.data('tooltip', (data = new Tooltip(this, options)))
      if (typeof option == 'string') data[option]()
    })
  }

  $.fn.tooltip.Constructor = Tooltip

  $.fn.tooltip.defaults = {
    animation: true
  , placement: 'bottom'
  , selector: false
  , template: '<div class="tooltip"><div class="tooltip-arrow"></div><div class="tooltip-inner"></div></div>'
  , trigger: 'hover'
  , title: ''
  , delay: 0
  }

}(window.jQuery);

$(function() {
  $('[rel="tooltip"]').tooltip()
})
/* ===========================================================
 * bootstrap-popover.js v2.0.4
 * http://twitter.github.com/bootstrap/javascript.html#popovers
 * ===========================================================
 * Copyright 2012 Twitter, Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 * =========================================================== */


!function ($) {

  "use strict"; // jshint ;_;


 /* POPOVER PUBLIC CLASS DEFINITION
  * =============================== */

  var Popover = function ( element, options ) {
    this.init('popover', element, options)
  }


  /* NOTE: POPOVER EXTENDS BOOTSTRAP-TOOLTIP.js
     ========================================== */

  Popover.prototype = $.extend({}, $.fn.tooltip.Constructor.prototype, {

    constructor: Popover

  , setContent: function () {
      var $tip = this.tip()
        , title = this.getTitle()
        , content = this.getContent()

      if (title === "") {
        $tip.find('.popover-title').remove()
        $tip.addClass('popover-no-title')
      } else {
        $tip.find('.popover-title')[this.isHTML(title) ? 'html' : 'text'](title)
      }
      $tip.find('.popover-content > *')[this.isHTML(content) ? 'html' : 'text'](content)

      $tip.removeClass('fade top bottom left right in')
    }

  , hasContent: function () {
      return this.getTitle() || this.getContent()
    }

  , getContent: function () {
      var content
        , $e = this.$element
        , o = this.options

      content = $e.attr('data-content')
        || (typeof o.content == 'function' ? o.content.call($e[0]) :  o.content)

      return content
    }

  , tip: function () {
      if (!this.$tip) {
        this.$tip = $(this.options.template)
      }
      return this.$tip
    }

  })


 /* POPOVER PLUGIN DEFINITION
  * ======================= */

  $.fn.popover = function (option) {
    return this.each(function () {
      var $this = $(this)
        , data = $this.data('popover')
        , options = typeof option == 'object' && option
      if (!data) $this.data('popover', (data = new Popover(this, options)))
      if (typeof option == 'string') data[option]()
    })
  }

  $.fn.popover.Constructor = Popover

  $.fn.popover.defaults = $.extend({} , $.fn.tooltip.defaults, {
    placement: 'right'
  , content: ''
  , template: '<div class="popover"><div class="arrow"></div><div class="popover-inner"><h4 class="popover-title"></h4><div class="popover-content"><p></p></div></div></div>'
  })

}(window.jQuery);

$(function() {
  $('[rel="popover"][data-original-title]').popover()
  $('[rel="popover"]').popover({placement: 'bottom'})
})
!(function($) {

  "use strict";

  var methods = {

    // Verifica os irmãos do checkbox.
    checkSiblings: function(checked, el) {
      var parent = el.parent().parent()
        , all = true

      el.siblings().each(function() {
        return all = ($(this).children('input[type="checkbox"]').prop('checked') === checked)
      })

      if (all && checked) {
        parent.children('input[type="checkbox"]').prop({
          indeterminate: false,
          checked: checked
        })
        methods.checkSiblings(checked, parent)

      } else if (all && !checked) {
        parent.children('input[type="checkbox"]').prop('checked', checked)
        parent.children('input[type="checkbox"]').prop('indeterminate', (parent.find('input[type="checkbox"]:checked').length > 0))
        methods.checkSiblings(checked, parent)

      } else {
        el.parents('li').children('input[type="checkbox"]').prop({
          indeterminate: true,
          checked: false
        })
      }
    },

    // Responsável pela parte de hierarquia de checkboxes.
    // Fonte: http://css-tricks.com/indeterminate-checkboxes/
    changeCheckBox: function(event) {
      var checked = $(this).prop('checked')
        , container = $(this).parent()

      container.find('input[type="checkbox"]').prop({
        indeterminate: false,
        checked: checked
      })

      methods.checkSiblings(checked, container)

      // Adiciona a classe que escurece o texto dos itens marcados.
      event.data.filterGroup.find('input[type="checkbox"]').each(function() {
        var checkbox = $(this)

        if (checkbox.prop('checked') || checkbox.prop('indeterminate')) {
          checkbox.parent().addClass(event.data.settings.filterCheckedClass)
        } else {
          checkbox.parent().removeClass(event.data.settings.filterCheckedClass)
        }
      })

      // Substitui o sub título do filtro.
      $(this).trigger('replaceSubTitle', [event.data.filterGroup])
    },

    // Desmarca totalmente um filtro.
    uncheckFilter: function(filterGroup, settings) {
      filterGroup.find('.' + settings.filterClass).removeClass(settings.filterActiveClass)
      filterGroup.find('.' + settings.filterSubTitleClass).text('')
      filterGroup.find('li').removeClass(settings.filterCheckedClass)
      filterGroup.find('input[type="checkbox"]').prop({
        checked: false,
        indeterminate: false
      })
    },

    // Substitui o sub título de um filtro de acordo com os checkboxes marcados.
    replaceSubTitle: function(event, filterGroup) {
      var checkedBoxes = filterGroup.find('input[type="checkbox"]:checked')
        , filter = filterGroup.find('.' + event.data.settings.filterClass)
        , subTitleText = ''

      if (checkedBoxes.length === 1) {
        subTitleText = checkedBoxes.siblings('label').text()
      } else if (checkedBoxes.length > 1) {
        // Subtrai um pois não conta a opção "Todos".
        subTitleText = (checkedBoxes.length - 1) + ' opções selecionadas'
      }

      // Caso especial para o filtro de cursos e disciplinas.
      if (filter.hasClass(event.data.settings.filterCoursesClass)) {
        var coursesCheckBoxes = filterGroup.find('.' + event.data.settings.filterLevel2ItemClass + ' > input[type="checkbox"]')
          , coursesCheckedBoxes = coursesCheckBoxes.filter(':checked')
          , coursesUnCheckedBoxes = coursesCheckBoxes.filter(function(index) {
            return $(this).prop('indeterminate')
          })

        // Cursos.
        if (coursesCheckedBoxes.length === 1) {
          subTitleText = coursesCheckedBoxes.siblings('label').text()
        } else if (coursesCheckedBoxes.length > 1) {
          subTitleText = coursesCheckedBoxes.length + ' cursos selecionados'
        }

        // Disciplinas.
        if (coursesUnCheckedBoxes.length >= 1) {
          var disciplinesCheckedBoxes = filterGroup.find('.' + event.data.settings.filterLevel3ItemClass + ' > input[type="checkbox"]:checked')

          if (disciplinesCheckedBoxes.length === 1) {
            subTitleText = disciplinesCheckedBoxes.siblings('label').text()
          } else if (disciplinesCheckedBoxes.length > 1) {
            subTitleText = disciplinesCheckedBoxes.length + ' disciplinas selecionadas'
          }
        }
      }

      // Adiciona a classe de filtro ativado.
      if (checkedBoxes.length >= 1) {
        filter.addClass(event.data.settings.filterActiveClass)
        // Desmarca os outros filtros.
        filterGroup.siblings().each(function() {
          methods.uncheckFilter($(this), event.data.settings)
        })
      } else {
        filter.removeClass(event.data.settings.filterActiveClass)
      }

      // Trata os nomes grandes.
      if (subTitleText.length > 28) {
        subTitleText = subTitleText.substring(0, 24) + '...'
      }

      filterGroup.find('.' + event.data.settings.filterSubTitleClass).text(subTitleText)
    },

    init: function(options) {
      var settings = $.extend({
          filterEverythingClass: 'filter-everything',
          filterActiveClass: 'filter-active',
          filterDropdownMenuClass: 'dropdown-menu',
          filterClass: 'filter',
          filterCoursesClass: 'filter-courses',
          filterLevel2ItemClass: 'filter-level-2-item',
          filterLevel3ItemClass: 'filter-level-3-item',
          filterSubTitleClass: 'filter-sub-title',
          filterCheckedClass: 'filter-checked'
        }, options)

      return this.each(function() {
        var reduFilter = $(this)
          , filterEverything = reduFilter.find('.' + settings.filterEverythingClass)
          , dropdownFilters = filterEverything.parent().siblings()

        // O filtro "Tudo" começa ativo.
        filterEverything.addClass(settings.filterActiveClass)
        // No estado ativado, desabilita todos os outros filtros.
        filterEverything.on('click', function(e) {
          dropdownFilters.each(function() {
            methods.uncheckFilter($(this), settings)
          })
        })

        // Para cada filtro.
        dropdownFilters.each(function() {
          var filterGroup = $(this)
          // Para cada checkbox.
          filterGroup.find('input[type="checkbox"]').each(function() {
            var checkbox = $(this)
            // Inicia desmarcado.
            checkbox.prop('checked', false)
            // Vincula o evento de substituir o sub título do filtro.
            checkbox.on('replaceSubTitle.reduFilter', {settings: settings}, methods.replaceSubTitle)
            checkbox.on('change', {settings: settings, filterGroup: filterGroup}, methods.changeCheckBox)
          })
        })

        // Impede que o dropdown feche ao ser clicado.
        reduFilter.find('.' + settings.filterDropdownMenuClass).on('click', function(e) {
          e.stopPropagation()
        })
      })
    }
  }

  $.fn.reduFilter = function(method) {
    if (methods[method]) {
      return methods[method].apply(this, Array.prototype.slice.call(arguments, 1))
    } else if (typeof method === 'object' || !method) {
      return methods.init.apply(this, arguments)
    } else {
      $.error('O método ' + method + ' não existe em jQuery.reduFilter')
    }
  }

}) (window.jQuery)

$(function() {
  // Adiciona os eventos dos filtros da visão geral.
  $('.filters-general-view').reduFilter()
})

!(function($) {

  "use strict";

  var methods = {

    // Adiciona um contador de caracteres.
    countChars: function(options) {
      var settings = $.extend({
        characterCounterTemplate: $('<span class="character-counter"></span>')
      }, options);

      return this.each(function() {
        var control = $(this)
          , controls = control.parent()
          , maxLength = control.attr('maxlength')
          , remainingCharsText = function(charCount) {
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

        control.on({
          focusin: function() {
            settings.characterCounterTemplate.text(remainingCharsText(control.val().length))
            settings.characterCounterTemplate.appendTo(controls)
          }
        , focusout: function() { settings.characterCounterTemplate.remove() }
        , keyup: function() { settings.characterCounterTemplate.text(remainingCharsText(control.val().length)) }
        })
      })
    },

    // Adições/remoções de classes para o controle lista de opções.
    optionList: function(options) {
        var settings = $.extend({
          optionListCheckedClass: 'control-option-list-checked'
        , optionListCheckbox: 'control-option-list-checkbox'
        , textAreaClass: 'input-area'
        , appendAreaClass: 'control-append-area'
        , blue2: '#73C3E6'
        }, options)

      return this.each(function() {
        var optionList = $(this)
          , textArea = optionList.children('.' + settings.textAreaClass)
          , appendArea = optionList.children('.' + settings.appendAreaClass)
          , checkbox = appendArea.children('.' + settings.optionListCheckbox)


        // Adiciona a classe optionListCheckedClass quando o checkbox estiver marcardo.

        if (checkbox.prop('checked')) {
          optionList.addClass(settings.optionListCheckedClass)
        }

        checkbox.on('click', function() {
          optionList.toggleClass(settings.optionListCheckedClass)
        })

        // Adiciona a borda blue2 ao botão quando o textarea está em foco.
        textArea.on({
          focusin: function() { appendArea.css('border-color', settings.blue2) }
        , focusout: function() { appendArea.css('border-color', '') }
        })
      })
    },

    // Adições/remoções de classes para o formulário de busca.
    search: function(options) {
        var settings = $.extend({
          iconMagnifierGray: 'icon-magnifier-gray_16_18'
        , iconMagnifierLightBlue: 'icon-magnifier-lightblue_16_18'
        , blue2: '#73C3E6'
        , controlAreaClass: 'control-area'
        , controlAppendAreaClass: 'control-append-area'
        , searchIconClass: 'control-search-icon'
        }, options)

      return this.each(function() {
        var form = $(this)
          , control = form.children('.' + settings.controlAreaClass)
          , button = form.children('.' + settings.controlAppendAreaClass)
          , icon = button.children('.' + settings.searchIconClass)

        control.on({
          focusin: function() {
            icon.removeClass(settings.iconMagnifierGray)
            icon.addClass(settings.iconMagnifierLightBlue)
            button.css('border-color', settings.blue2)
          }
        , focusout: function() {
            icon.removeClass(settings.iconMagnifierLightBlue)
            icon.addClass(settings.iconMagnifierGray)
            button.css('border-color', '')
          }
        })
      })
    },

    // Adiciona/remove a classe indicativa de controle em foco.
    toggleFocusLabel: function(options) {
      var settings = $.extend({
        // Classe adicionada quando o controle está me foco.
        controlFocusedClass: 'control-focused'
        // Classe que identifica o container do controle.
      , controlGroupClass: 'control-group'
      }, options)

      $(this).parents('.' + settings.controlGroupClass).toggleClass(settings.controlFocusedClass)
    },

    // Adiciona/remove uma classe ao rótulo do checkbox/radio quando está selecionado/desmarcado.
    darkLabel: function(options) {
      var settings = $.extend({
        // Classe adicionada quando o controle está marcado.
        controlCheckedClass: 'control-checked'
        // Classe que identifica um radio button.
      , radioClass: 'radio'
      , darkenLabel: function(label) {
          label.toggleClass(settings.controlCheckedClass)
          label.siblings('.' + settings.radioClass).removeClass(settings.controlCheckedClass)
        }
      }, options)

      return this.each(function() {
        var control = $(this)
          , label = control.parent()

        if (control.prop('checked')) { label.addClass(settings.controlCheckedClass) }

        control.on('change', function() { settings.darkenLabel(label) })
      })
    },

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

    styleInputFile: function(options) {
      var settings = $.extend({
        buttonDefault: 'button-default'
      , buttonText: 'Escolher arquivo'
      , filePath: 'control-file-text'
      , filePathText: 'Nenhum arquivo selecionado.'
      , wrapper: 'control-file-wrapper'
      }, options)

      return this.each(function() {
        var $input = $(this).css('opacity', 0)
          , inputVal = $input.val()
          , $button = $(document.createElement('a')).addClass(settings.buttonDefault).text(settings.buttonText)
          , $filePath = $(document.createElement('span')).addClass(settings.filePath).text(settings.filePathText)
          , $wrapper = $(document.createElement('div')).addClass(settings.wrapper).append($button).append($filePath)
          , $controlParent = $input.parent()

        $wrapper.appendTo($controlParent)
        // Ajusta a altura do pai.
        $controlParent.height($wrapper.height())

        // No FF, se um arquivo for escolhido e der refresh, o input mantém o valor.
        if (inputVal !== '') {
          $filePath.text(inputVal)
        }

        // Repassa o clique pro input file.
        $button.on('click', function(e) {
          e.preventDefault
          $input.trigger('click')
        })

        // Repassa o nome do arquivo para o span.
        $input.on('change', function() {
          var value = $input.val()

          if (value === '') {
            value = settings.filePathText
          } else {
            // Remove o 'C:\fakepath\' que alguns navegadores adicionam.
            value = value.replace('C:\\fakepath\\', '')
          }

          $filePath.text(value)
        })
      })
    },

    // Abilita o submit quando pelo menos um checkbox esta marcado.
    formChecklist: function(options) {
      return this.each(function() {
        var $form = $(this)
          , $checkboxes = $form.find('input[type="checkbox"]')
          , $submit = $form.find('input[type="submit"]')

        // Desabilita o submit por padrão.
        $submit.attr('disabled', 'disabled')

        // Verifica inicialmente se existe algum checkbox marcardo.
        // É o caso do refresh depois de marcar um checkbox.
        if ($checkboxes.filter(':checked').length > 0) {
          $submit.removeAttr('disabled')
        }

        $checkboxes.each(function() {
          var $checkbox = $(this)

          $checkbox.on('change', function() {
            // Se o checkbox foi selecionado, abilita o submit.
            if ($checkbox.is(':checked')) {
              $submit.removeAttr('disabled')
            } else {
              // Se foi o último a ser desmarcado, desabilita o submit.
              if ($checkboxes.filter(':checked').length === 0) {
                $submit.attr('disabled', 'disabled')
              }
            }
          })
        })
      })
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
  $('input[type="text"][maxlength], input[type="password"][maxlength], textarea[maxlength]').reduForm('countChars');

  $(document).on('focus blur', 'input[type="text"], input[type="password"], input[type="file"], textarea, select', function(e) {
    $(this).reduForm('toggleFocusLabel')
  })

  $('input[type="radio"], input[type="checkbox"]').reduForm('darkLabel')

  $(".form-search").reduForm("search")

  $('.control-option-list').reduForm('optionList')

  $('textarea[rows]').reduForm('resizeByRows')

  $('input[type="file"]').reduForm('styleInputFile')

  $('.form-checklist').reduForm('formChecklist')

  // Plugins.

  $('textarea').autosize()

  placeHolderConfig = {
    // Nome da classe usada para estilizar o placeholder.
    className: 'placeholder'
    // Mostra o texto do placeholder para leitores de tela ou não.
  , visibleToScreenreaders : false
    // Classe usada para esconder visualmente o placeholder.
  , visibleToScreenreadersHideClass : 'placeholder-hide-except-screenreader'
    // Classe usada para esconder o placeholder de tudo.
  , visibleToNoneHideClass : 'placeholder-hide'
    // Ou esconde o placeholder no focus ou na hora de digitação.
  , hideOnFocus : false
    // Remove esta classe do label (para consertar labels escondidos).
  , removeLabelClass : 'visuallyhidden'
    // Substitui o label acima com esta classe.
  , hiddenOverrideClass : 'visuallyhidden-with-placeholder'
    // Permite a substituição do removeLabelClass com hiddenOverrideClass.
  , forceHiddenOverride : true
    // Aplica o polyfill até mesmo nos navegadores com suporte nativo.
  , forceApply : false
    // Inicia automaticamente.
  , autoInit : true
  }
})

!(function($) {

  'use strict';

  var methods = {

    init: function(options) {
      var settings = $.extend({
          'linkTargetClass': 'link-target'
        }, options)

      return this.each(function() {
        var container = $(this)
          , link = container.find('.' + settings.linkTargetClass)

          container.on('click', function(e) {
            if (!$(e.target).is('input[type="checkbox"]')) {
              window.location = link.attr('href')
            }
          })
        })
      }

  }

  $.fn.reduLinks = function(method) {
    if (methods[method]) {
      return methods[method].apply(this, Array.prototype.slice.call(arguments, 1))
    } else if (typeof method === 'object' || !method) {
      return methods.init.apply(this, arguments)
    } else {
      $.error('O método ' + method + ' não existe em jQuery.reduLinks')
    }
  }

}) (window.jQuery)

$(function() {
  $('.link-container').reduLinks()
})
!(function($) {

  "use strict";

  var methods = {

    toggleDropdown: function(listMixItem, openClass, listMixHeaderLegend, listMixInfoClass, listMixBody) {
      if (listMixItem.hasClass(openClass)) {
        listMixItem.removeClass(openClass)
        listMixHeaderLegend.css("visibility", "visible")
        listMixInfoClass.show()
      } else {
        listMixItem.addClass(openClass)
        listMixHeaderLegend.css("visibility", "hidden")
        listMixInfoClass.hide()
      }

      listMixBody.toggle(150, "swing");
    },

    listMix: function(options) {
      var settings = $.extend({
          "buttonDrownClass": "button-dropdown:not(.button-disabled)",
          "openClass": "open",
          "listMixBodyClass": "list-mix-body",
          "listMixHeaderLegend": "list-mix-header .legend",
          "listMixInfoClass": "list-mix-info"
        }, options)

      return this.each(function() {
        var listMix = $(this),
            listMixItems = listMix.children()

        listMixItems.each(function() {
          var listMixItem = $(this),
              buttonDropdown = listMixItem.find("." + settings.buttonDrownClass),
              listMixBody = listMixItem.find("." + settings.listMixBodyClass),
              listMixHeaderLegend = listMixItem.find("." + settings.listMixHeaderLegend),
              listMixInfoClass = listMixItem.find("." + settings.listMixInfoClass),
              listMixHeader = listMixItem.find(".list-mix-header")

          buttonDropdown.on("click", function() {
            methods.toggleDropdown(listMixItem, settings.openClass, listMixHeaderLegend, listMixInfoClass, listMixBody)
          })
        })
      })
    },

    init: function(options) {

    }

  }

  $.fn.reduList = function(method) {
    if (methods[method]) {
      return methods[method].apply(this, Array.prototype.slice.call(arguments, 1))
    } else if (typeof method === "object" || !method) {
      return methods.init.apply(this, arguments)
    } else {
      $.error("O método " + method + " não existe em jQuery.reduList")
    }
  }

}) (window.jQuery)

$(function() {
  $(".list-mix").reduList("listMix")
})
$(function() {
  //Desabilita href dos links com estilo de botão, quando no estado desabilidado.
  $(".button-disabled").live("click", function(e) {
    e.preventDefault()
  });
});

 // Responder status
$("a.reply-status, .cancel", ".statuses").live("click", function(e){
    e.preventDefault();
    $(this).parents("ul:first").next(".create-response").slideToggle(150, "swing");
    $(this).parents("ul:first").next(".create-response").find("textarea").focus();
});
!(function($) {

  'use strict';

  var methods = {

    init: function(options) {
      var settings = $.extend({
          'checkboxSelectedClass': 'table-checkbox-selected'
        }, options)

      return this.each(function() {
        var checkbox = $(this),
            row = checkbox.parents('tr')

        if (checkbox.is(':checked')) {
          row.addClass(settings.checkboxSelectedClass)
        }

        checkbox.on('change', function() {
          row.toggleClass(settings.checkboxSelectedClass)
        })
      })
    }
  }

  $.fn.reduTables = function(method) {
    if (methods[method]) {
      return methods[method].apply(this, Array.prototype.slice.call(arguments, 1))
    } else if (typeof method === 'object' || !method) {
      return methods.init.apply(this, arguments)
    } else {
      $.error('O método ' + method + ' não existe em jQuery.reduTables')
    }
  }

}) (window.jQuery)

$(function() {
  $('.form-checklist td input[type="checkbox"]').reduTables()
})

!(function($) {

  'use strict';

  var settings = {
    originalInput: 'control-autocomplete-input'
  , tokenInputPrefix: 'token-input-'
  , triggerInviteByMail: 'inviteByMail.reduAutocomplete'
  , dropdown: 'control-autocomplete-dropdown'
  , name: 'control-autocomplete-name'
  , mail: 'control-autocomplete-mail'
  , suggestion: 'control-autocomplete-suggestion'
  , inviteClickText: 'Clique aqui para convidar este endereço de e-mail'
  , buttonStyle: 'button-primary'
  , listMix: 'list-mix'
  , listMixItem: 'list-mix-item'
  , listMixInner: 'list-mix-inner'
  , close: 'control-autocomplete-close'
  , iconClose: 'icon-close-gray_16_18 show'
  , addedInfo: 'control-autocomplete-added-info'
  , inviteText: '(Convidar para o Redu)'
  , invites: 'control-autocomplete-invites'
  }

  var methods = {
    // Cria um elemento usado para convidar alguém para o Redu por e-mail.
    createInvite: function(mail) {
      return $('<li class="' + settings.listMixItem + '"><div class="' + settings.listMixInner + '"><span class="' + settings.close + '"><span class="' + settings.iconClose + '"></span></span><div class="' + settings.addedInfo + '"><span class="' + settings.name + '">' + mail + '</span><span class="' + settings.mail + '">' + settings.inviteText + '</span></div></div></li>')
    }

    // Quando um e-mail é digitado, sugere o envio do convite ao Redu.
  , inviteByMail: function(options) {
      settings = $.extend(settings, options)

      return this.each(function() {
        var control = $(this)
          , originalInput = control.find('.' + settings.originalInput)

        // Este evento será lançado quando nenhum resultado for encontrado.
        originalInput.on(settings.triggerInviteByMail, function() {
          var input = $.trim(control.find('#' + settings.tokenInputPrefix + originalInput.attr('id')).val())
            , emailRegex = /^([a-zA-Z0-9])+@([a-zA-Z0-9])+\.([a-zA-Z])+([a-zA-Z])+/

          // Verifica se é um e-mail.
          if (emailRegex.test(input)) {
            var dropdown = control.find('.' + settings.dropdown)
              , inviteButton = $(document.createElement('button')).addClass(settings.buttonStyle).text(settings.inviteClickText)
              , listMix = control.find('.' + settings.listMix)

            // Incli o botão de adicionar.
            dropdown.html(inviteButton)
            inviteButton.on('click', function(e) {
              e.preventDefault()
              var isAlreadyIn = false
                , inputInvites = control.find('.' + settings.invites)

              // Verifica se o e-mail já está incluso.
              if (inputInvites.val().indexOf(input) >= 0) {
                isAlreadyIn = true
              }

              // Adiciona se não estiver.
              if (!isAlreadyIn) {
                var inviteChosen = methods.createInvite(input)
                  , close = inviteChosen.find('.' + settings.close)

                // Adiciona o remover para o ícone de fechar.
                close.on('click', function(e) {
                  e.preventDefault
                  var item = $(this).parents('.' + settings.listMixItem)

                  item.remove()
                  // Remove o e-mail dos valores do input hidden.
                  inputInvites.val($.trim(inputInvites.val().replace(',', ' ').replace(input, '')).replace(' ', ',').replace(',,', ','))
                })

                // Adiciona o e-mail aos valores do input hidden.
                var mails = $.trim(inputInvites.val() + ' ' + input)
                inputInvites.val((mails.split(' ')).join(','))

                // Adiciona a lista.
                listMix.append(inviteChosen)
              }
            })
          }
        })
      })
    }

  , init: function(options) {
      methods.inviteByMail(options)
    }
  }

  $.fn.reduAutocomplete = function(method) {
    if (methods[method]) {
      return methods[method].apply(this, Array.prototype.slice.call(arguments, 1))
    } else if (typeof method === 'object' || !method) {
      return methods.init.apply(this, arguments)
    } else {
      $.error('O método ' + method + ' não existe em jQuery.reduAutocomplete')
    }
  }

}) (window.jQuery)

$(function() {
  $('.control-invite-by-mail').reduAutocomplete('inviteByMail')
})

!(function($) {

  "use strict";

  var methods = {
    checkLabel: function(checkbox) {
      var label = checkbox.siblings("label")
      if (checkbox.prop("checked")) {
        label.addClass("local-nav-checked icon-confirm-green_16_18-after")
      } else {
        label.removeClass("local-nav-checked icon-confirm-green_16_18-after")
      }
    },

    init: function() {
      return this.each(function() {
        var localNav = $(this)

        localNav.find("li").click(function(e) {
          window.location = $(this).children("a").first().attr("href")
        })

        var checkboxes = localNav.find('input[type="checkbox"]')
        checkboxes.filter(":checked").each(function() {
          methods.checkLabel($(this))
        })

        checkboxes.change(function(e) {
          methods.checkLabel($(this))
        })
      })
    }
  }

  $.fn.localNav = function(method) {
    if (methods[method]) {
      return methods[method].apply(this, Array.prototype.slice.call(arguments, 1))
    } else if (typeof method === "object" || !method) {
      return methods.init.apply(this, arguments)
    } else {
      $.error("O método " + method + " não existe em jQuery.localNav")
    }
  }

}) (window.jQuery)

$(function() {
  $(".local-nav").localNav();
})
!(function($) {

  'use strict';

  var classes = {
    // Wrapper.
    modal: 'modal'
    // Conteúdo.
  , modalBody: 'modal-body'
    // Seta.
  , scrollArrow: 'modal-scroll-arrow'
  }

  var methods = {
    // Usado para conseguir o tamanho de um elemento com display none.
    displayHidden: function($element) {
      var wasVisible = true

      if ($element.css('display') === 'none') {
        $element.css({
          'visibility': 'hidden'
        , 'display': 'block'})
        wasVisible = false
      }

      return wasVisible
    }

    // Retorna o elemento para display none.
  , displayVisible: function($element) {
      $element.css({
        'visibility': 'visible'
      , 'display': 'none'})
    }

  , fitContent: function($modal, settings) {
    var $modalBody = $modal.find('.' + classes.modalBody)
      , modalTop = parseInt($modal.css('top'), 10)
      , wasVisible

    wasVisible = methods.displayHidden($modal)

    // O novo tamanho do corpo é: tamanho atual + (altura visível do navegador - espaçamento inferior - topo do modal - altura do modal)
    var newHeight = $modalBody.height() + $(window).height() - settings.bottomMargin - modalTop - $modal.height() + "px"

    var innerHeight = $modalBody[0].scrollHeight - (parseInt($modalBody.css('padding-top'), 10) + parseInt($modalBody.css('padding-bottom'), 10))

    if (innerHeight <= parseInt(newHeight, 10)) {
      newHeight = innerHeight
    }

    $modalBody.css('max-height', newHeight)
    $modalBody.css('height', newHeight)

    if (!wasVisible) {
      methods.displayVisible($modal)
    }
  }

    // Preenche verticalmente a janela modal.
  , fillHeight: function(options) {
      var settings = $.extend({
          // Margem inferior.
          bottomMargin: 20
        }, options)

      return this.each(function() {
        var $modal = $(this)
        $modal.on('fitContent.redu', function(e) {
          methods.fitContent($modal, settings)
        })
        $modal.trigger('fitContent.redu')
      })
    }

    // Verifica se um elemento apresenta a barra de scroll vertical.
  , hasScrollBar: function($element) {
      var element = $element.get(0)
      return (element.scrollHeight > element.clientHeight)
    }

    // Controla a seta mostrada quando há barra de scroll vertical.
  , scrollArrow: function(options) {
      var settings = $.extend({
        // Caractere simbolizando uma seta para cima.
        arrowUp: '↑'
        // Caractere simbolizando uma seta para baixo.
      , arrowDown: '↓'
        // Largura da seta.
      , arrowWidth: 9
      }, options)

      return this.each(function() {
        var $modalBody = $(this)
          , $modal = $modalBody.parent('.' + classes.modal)

        methods.displayHidden($modal)

        if (methods.hasScrollBar($modalBody)) {
          var $scrollArrow =
                $(document.createElement('span'))
                  .addClass(classes.scrollArrow)
                  .html(settings.arrowDown)
            , modalBodyOffset = $modalBody.offset()
            , margin = (parseInt($modalBody.css('padding-left'), 10) - settings.arrowWidth) / 2
            , arrowUpPosition = modalBodyOffset.top - $(window).scrollTop() + 5
            , arrowDownPosition = arrowUpPosition + $modalBody.height()

          $scrollArrow.css({
            'top': arrowDownPosition
          , 'left': modalBodyOffset.left + margin
          })

          $modalBody.append($scrollArrow)
          $modalBody.scroll(function() {
            var scrollTop = $modalBody.scrollTop()

            if (scrollTop === 0) {
              // Barra de rolagem no topo, exibe seta para baixo.
              $scrollArrow.css('top', arrowDownPosition).html(settings.arrowDown)
            } else if (scrollTop + $modalBody.innerHeight() >= $modalBody.get(0).scrollHeight) {
              // Barra de rolagem no fundo, exibe seta para cima.
              $scrollArrow.css('top', arrowUpPosition).html(settings.arrowUp)
            }
          })
        }

        methods.displayVisible($modal)
      })
    }
  }

  $.fn.reduModal = function(method) {
    if (methods[method]) {
      return methods[method].apply(this, Array.prototype.slice.call(arguments, 1))
    } else if (typeof method === 'object' || !method) {
      return methods.init.apply(this, arguments)
    } else {
      $.error('O método ' + method + ' não existe em jQuery.reduModal')
    }
  }

}) (window.jQuery)

$(function() {
  $('.modal').reduModal('fillHeight')
  $('.modal-scroll').reduModal('scrollArrow')
})

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
  , imgPath: 'images/'
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
        var $submit = $this.find('input:submit')
          , spinnerClass = settings.spinnerCircularGray

        if ($submit.hasClass(settings.buttonDefault)) {
          spinnerClass = settings.spinnerCircularBlue
        }

        $submit
          .addClass(spinnerClass)
          .prop('disabled', true)
          .data('spinnerClass', spinnerClass)
          .data('content', $submit.val())
          .css({ 'width': $submit.outerWidth(), 'height': $submit.outerHeight() })
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

        // Retorna as outras classes, que não a do botão.
        var otherClasses = function(classes) {
          var otherClasses = []

          classes = classes.split(' ')
          $.each(classes, function(index, value) {
            if (value !== settings.buttonDefault
                && value !== settings.buttonPrimary
                && value !== settings.buttonDanger
                && value !== settings.buttonSuccess
                && value !== '') {
              otherClasses.push(value)
            }
          })

          return otherClasses.join(' ')
        }

        var content = $this.html()
          , width = $this.outerWidth()
          , height = $this.outerHeight()
          , classes = otherClasses($this.attr('class'))
          , $spinner = $(document.createElement('img')).attr('src', spinnerImg).css(settings.spinnerCSS)

        $this
          .addClass(settings.buttonDisabled)
          .removeClass(classes)
          .data('content', content)
          .data('class', classes)
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
        var $submit = $this.find('input:submit')

        $submit
          .removeClass($submit.data('spinnerClass'))
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
