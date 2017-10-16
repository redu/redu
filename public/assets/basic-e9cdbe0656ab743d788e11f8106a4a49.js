(function($, undefined) {

/**
 * Unobtrusive scripting adapter for jQuery
 *
 * Requires jQuery 1.6.0 or later.
 * https://github.com/rails/jquery-ujs

 * Uploading file using rails.js
 * =============================
 *
 * By default, browsers do not allow files to be uploaded via AJAX. As a result, if there are any non-blank file fields
 * in the remote form, this adapter aborts the AJAX submission and allows the form to submit through standard means.
 *
 * The `ajax:aborted:file` event allows you to bind your own handler to process the form submission however you wish.
 *
 * Ex:
 *     $('form').live('ajax:aborted:file', function(event, elements){
 *       // Implement own remote file-transfer handler here for non-blank file inputs passed in `elements`.
 *       // Returning false in this handler tells rails.js to disallow standard form submission
 *       return false;
 *     });
 *
 * The `ajax:aborted:file` event is fired when a file-type input is detected with a non-blank value.
 *
 * Third-party tools can use this hook to detect when an AJAX file upload is attempted, and then use
 * techniques like the iframe method to upload the file instead.
 *
 * Required fields in rails.js
 * ===========================
 *
 * If any blank required inputs (required="required") are detected in the remote form, the whole form submission
 * is canceled. Note that this is unlike file inputs, which still allow standard (non-AJAX) form submission.
 *
 * The `ajax:aborted:required` event allows you to bind your own handler to inform the user of blank required inputs.
 *
 * !! Note that Opera does not fire the form's submit event if there are blank required inputs, so this event may never
 *    get fired in Opera. This event is what causes other browsers to exhibit the same submit-aborting behavior.
 *
 * Ex:
 *     $('form').live('ajax:aborted:required', function(event, elements){
 *       // Returning false in this handler tells rails.js to submit the form anyway.
 *       // The blank required inputs are passed to this function in `elements`.
 *       return ! confirm("Would you like to submit the form with missing info?");
 *     });
 */

  // Shorthand to make it a little easier to call public rails functions from within rails.js
  var rails;

  $.rails = rails = {
    // Link elements bound by jquery-ujs
    linkClickSelector: 'a[data-confirm], a[data-method], a[data-remote], a[data-disable-with]',

    // Select elements bound by jquery-ujs
    inputChangeSelector: 'select[data-remote], input[data-remote], textarea[data-remote]',

    // Form elements bound by jquery-ujs
    formSubmitSelector: 'form',

    // Form input elements bound by jquery-ujs
    formInputClickSelector: 'form input[type=submit], form input[type=image], form button[type=submit], form button:not(button[type])',

    // Form input elements disabled during form submission
    disableSelector: 'input[data-disable-with], button[data-disable-with], textarea[data-disable-with]',

    // Form input elements re-enabled after form submission
    enableSelector: 'input[data-disable-with]:disabled, button[data-disable-with]:disabled, textarea[data-disable-with]:disabled',

    // Form required input elements
    requiredInputSelector: 'input[name][required]:not([disabled]),textarea[name][required]:not([disabled])',

    // Form file input elements
    fileInputSelector: 'input:file',

    // Link onClick disable selector with possible reenable after remote submission
    linkDisableSelector: 'a[data-disable-with]',

    // Make sure that every Ajax request sends the CSRF token
    CSRFProtection: function(xhr) {
      var token = $('meta[name="csrf-token"]').attr('content');
      if (token) xhr.setRequestHeader('X-CSRF-Token', token);
    },

    // Triggers an event on an element and returns false if the event result is false
    fire: function(obj, name, data) {
      var event = $.Event(name);
      obj.trigger(event, data);
      return event.result !== false;
    },

    // Default confirm dialog, may be overridden with custom confirm dialog in $.rails.confirm
    confirm: function(message) {
      return confirm(message);
    },

    // Default ajax function, may be overridden with custom function in $.rails.ajax
    ajax: function(options) {
      return $.ajax(options);
    },

    // Default way to get an element's href. May be overridden at $.rails.href.
    href: function(element) {
      return element.attr('href');
    },

    // Submits "remote" forms and links with ajax
    handleRemote: function(element) {
      var method, url, data, crossDomain, dataType, options;

      if (rails.fire(element, 'ajax:before')) {
        crossDomain = element.data('cross-domain') || null;
        dataType = element.data('type') || ($.ajaxSettings && $.ajaxSettings.dataType);

        if (element.is('form')) {
          method = element.attr('method');
          url = element.attr('action');
          data = element.serializeArray();
          // memoized value from clicked submit button
          var button = element.data('ujs:submit-button');
          if (button) {
            data.push(button);
            element.data('ujs:submit-button', null);
          }
        } else if (element.is(rails.inputChangeSelector)) {
          method = element.data('method');
          url = element.data('url');
          data = element.serialize();
          if (element.data('params')) data = data + "&" + element.data('params');
        } else {
          method = element.data('method');
          url = rails.href(element);
          data = element.data('params') || null;
        }

        options = {
          type: method || 'GET', data: data, dataType: dataType, crossDomain: crossDomain,
          // stopping the "ajax:beforeSend" event will cancel the ajax request
          beforeSend: function(xhr, settings) {
            if (settings.dataType === undefined) {
              xhr.setRequestHeader('accept', '*/*;q=0.5, ' + settings.accepts.script);
            }
            return rails.fire(element, 'ajax:beforeSend', [xhr, settings]);
          },
          success: function(data, status, xhr) {
            element.trigger('ajax:success', [data, status, xhr]);
          },
          complete: function(xhr, status) {
            element.trigger('ajax:complete', [xhr, status]);
          },
          error: function(xhr, status, error) {
            element.trigger('ajax:error', [xhr, status, error]);
          }
        };
        // Only pass url to `ajax` options if not blank
        if (url) { options.url = url; }

        return rails.ajax(options);
      } else {
        return false;
      }
    },

    // Handles "data-method" on links such as:
    // <a href="/users/5" data-method="delete" rel="nofollow" data-confirm="Are you sure?">Delete</a>
    handleMethod: function(link) {
      var href = rails.href(link),
        method = link.data('method'),
        target = link.attr('target'),
        csrf_token = $('meta[name=csrf-token]').attr('content'),
        csrf_param = $('meta[name=csrf-param]').attr('content'),
        form = $('<form method="post" action="' + href + '"></form>'),
        metadata_input = '<input name="_method" value="' + method + '" type="hidden" />';

      if (csrf_param !== undefined && csrf_token !== undefined) {
        metadata_input += '<input name="' + csrf_param + '" value="' + csrf_token + '" type="hidden" />';
      }

      if (target) { form.attr('target', target); }

      form.hide().append(metadata_input).appendTo('body');
      form.submit();
    },

    /* Disables form elements:
      - Caches element value in 'ujs:enable-with' data store
      - Replaces element text with value of 'data-disable-with' attribute
      - Sets disabled property to true
    */
    disableFormElements: function(form) {
      form.find(rails.disableSelector).each(function() {
        var element = $(this), method = element.is('button') ? 'html' : 'val';
        element.data('ujs:enable-with', element[method]());
        element[method](element.data('disable-with'));
        element.prop('disabled', true);
      });
    },

    /* Re-enables disabled form elements:
      - Replaces element text with cached value from 'ujs:enable-with' data store (created in `disableFormElements`)
      - Sets disabled property to false
    */
    enableFormElements: function(form) {
      form.find(rails.enableSelector).each(function() {
        var element = $(this), method = element.is('button') ? 'html' : 'val';
        if (element.data('ujs:enable-with')) element[method](element.data('ujs:enable-with'));
        element.prop('disabled', false);
      });
    },

   /* For 'data-confirm' attribute:
      - Fires `confirm` event
      - Shows the confirmation dialog
      - Fires the `confirm:complete` event

      Returns `true` if no function stops the chain and user chose yes; `false` otherwise.
      Attaching a handler to the element's `confirm` event that returns a `falsy` value cancels the confirmation dialog.
      Attaching a handler to the element's `confirm:complete` event that returns a `falsy` value makes this function
      return false. The `confirm:complete` event is fired whether or not the user answered true or false to the dialog.
   */
    allowAction: function(element) {
      var message = element.data('confirm'),
          answer = false, callback;
      if (!message) { return true; }

      if (rails.fire(element, 'confirm')) {
        answer = rails.confirm(message);
        callback = rails.fire(element, 'confirm:complete', [answer]);
      }
      return answer && callback;
    },

    // Helper function which checks for blank inputs in a form that match the specified CSS selector
    blankInputs: function(form, specifiedSelector, nonBlank) {
      var inputs = $(), input,
        selector = specifiedSelector || 'input,textarea';
      form.find(selector).each(function() {
        input = $(this);
        // Collect non-blank inputs if nonBlank option is true, otherwise, collect blank inputs
        if (nonBlank ? input.val() : !input.val()) {
          inputs = inputs.add(input);
        }
      });
      return inputs.length ? inputs : false;
    },

    // Helper function which checks for non-blank inputs in a form that match the specified CSS selector
    nonBlankInputs: function(form, specifiedSelector) {
      return rails.blankInputs(form, specifiedSelector, true); // true specifies nonBlank
    },

    // Helper function, needed to provide consistent behavior in IE
    stopEverything: function(e) {
      $(e.target).trigger('ujs:everythingStopped');
      e.stopImmediatePropagation();
      return false;
    },

    // find all the submit events directly bound to the form and
    // manually invoke them. If anyone returns false then stop the loop
    callFormSubmitBindings: function(form, event) {
      var events = form.data('events'), continuePropagation = true;
      if (events !== undefined && events['submit'] !== undefined) {
        $.each(events['submit'], function(i, obj){
          if (typeof obj.handler === 'function') return continuePropagation = obj.handler(event);
        });
      }
      return continuePropagation;
    },

    //  replace element's html with the 'data-disable-with' after storing original html
    //  and prevent clicking on it
    disableElement: function(element) {
      element.data('ujs:enable-with', element.html()); // store enabled state
      element.html(element.data('disable-with')); // set to disabled state
      element.bind('click.railsDisable', function(e) { // prevent further clicking
        return rails.stopEverything(e)
      });
    },

    // restore element to its original state which was disabled by 'disableElement' above
    enableElement: function(element) {
      if (element.data('ujs:enable-with') !== undefined) {
        element.html(element.data('ujs:enable-with')); // set to old enabled state
        // this should be element.removeData('ujs:enable-with')
        // but, there is currently a bug in jquery which makes hyphenated data attributes not get removed
        element.data('ujs:enable-with', false); // clean up cache
      }
      element.unbind('click.railsDisable'); // enable element
    }

  };

  $.ajaxPrefilter(function(options, originalOptions, xhr){ if ( !options.crossDomain ) { rails.CSRFProtection(xhr); }});

  $(document).delegate(rails.linkDisableSelector, 'ajax:complete', function() {
      rails.enableElement($(this));
  });

  $(document).delegate(rails.linkClickSelector, 'click.rails', function(e) {
    var link = $(this), method = link.data('method'), data = link.data('params');
    if (!rails.allowAction(link)) return rails.stopEverything(e);

    if (link.is(rails.linkDisableSelector)) rails.disableElement(link);

    if (link.data('remote') !== undefined) {
      if ( (e.metaKey || e.ctrlKey) && (!method || method === 'GET') && !data ) { return true; }

      if (rails.handleRemote(link) === false) { rails.enableElement(link); }
      return false;

    } else if (link.data('method')) {
      rails.handleMethod(link);
      return false;
    }
  });

  $(document).delegate(rails.inputChangeSelector, 'change.rails', function(e) {
    var link = $(this);
    if (!rails.allowAction(link)) return rails.stopEverything(e);

    rails.handleRemote(link);
    return false;
  });

  $(document).delegate(rails.formSubmitSelector, 'submit.rails', function(e) {
    var form = $(this),
      remote = form.data('remote') !== undefined,
      blankRequiredInputs = rails.blankInputs(form, rails.requiredInputSelector),
      nonBlankFileInputs = rails.nonBlankInputs(form, rails.fileInputSelector);

    if (!rails.allowAction(form)) return rails.stopEverything(e);

    // skip other logic when required values are missing or file upload is present
    if (blankRequiredInputs && form.attr("novalidate") == undefined && rails.fire(form, 'ajax:aborted:required', [blankRequiredInputs])) {
      return rails.stopEverything(e);
    }

    if (remote) {
      if (nonBlankFileInputs) {
        return rails.fire(form, 'ajax:aborted:file', [nonBlankFileInputs]);
      }

      // If browser does not support submit bubbling, then this live-binding will be called before direct
      // bindings. Therefore, we should directly call any direct bindings before remotely submitting form.
      if (!$.support.submitBubbles && $().jquery < '1.7' && rails.callFormSubmitBindings(form, e) === false) return rails.stopEverything(e);

      rails.handleRemote(form);
      return false;

    } else {
      // slight timeout so that the submit button gets properly serialized
      setTimeout(function(){ rails.disableFormElements(form); }, 13);
    }
  });

  $(document).delegate(rails.formInputClickSelector, 'click.rails', function(event) {
    var button = $(this);

    if (!rails.allowAction(button)) return rails.stopEverything(event);

    // register the pressed submit button
    var name = button.attr('name'),
      data = name ? {name:name, value:button.val()} : null;

    button.closest('form').data('ujs:submit-button', data);
  });

  $(document).delegate(rails.formSubmitSelector, 'ajax:beforeSend.rails', function(event) {
    if (this == event.target) rails.disableFormElements($(this));
  });

  $(document).delegate(rails.formSubmitSelector, 'ajax:complete.rails', function(event) {
    if (this == event.target) rails.enableFormElements($(this));
  });

})( jQuery );
/* Modernizr 2.6.2 (Custom Build) | MIT & BSD
 * Build: http://modernizr.com/download/#-borderradius-boxshadow-multiplebgs-textshadow-cssgradients-csstransitions-shiv-cssclasses-testprop-testallprops-prefixes-domprefixes-load
 */

;window.Modernizr=function(a,b,c){function y(a){j.cssText=a}function z(a,b){return y(m.join(a+";")+(b||""))}function A(a,b){return typeof a===b}function B(a,b){return!!~(""+a).indexOf(b)}function C(a,b){for(var d in a){var e=a[d];if(!B(e,"-")&&j[e]!==c)return b=="pfx"?e:!0}return!1}function D(a,b,d){for(var e in a){var f=b[a[e]];if(f!==c)return d===!1?a[e]:A(f,"function")?f.bind(d||b):f}return!1}function E(a,b,c){var d=a.charAt(0).toUpperCase()+a.slice(1),e=(a+" "+o.join(d+" ")+d).split(" ");return A(b,"string")||A(b,"undefined")?C(e,b):(e=(a+" "+p.join(d+" ")+d).split(" "),D(e,b,c))}var d="2.6.2",e={},f=!0,g=b.documentElement,h="modernizr",i=b.createElement(h),j=i.style,k,l={}.toString,m=" -webkit- -moz- -o- -ms- ".split(" "),n="Webkit Moz O ms",o=n.split(" "),p=n.toLowerCase().split(" "),q={},r={},s={},t=[],u=t.slice,v,w={}.hasOwnProperty,x;!A(w,"undefined")&&!A(w.call,"undefined")?x=function(a,b){return w.call(a,b)}:x=function(a,b){return b in a&&A(a.constructor.prototype[b],"undefined")},Function.prototype.bind||(Function.prototype.bind=function(b){var c=this;if(typeof c!="function")throw new TypeError;var d=u.call(arguments,1),e=function(){if(this instanceof e){var a=function(){};a.prototype=c.prototype;var f=new a,g=c.apply(f,d.concat(u.call(arguments)));return Object(g)===g?g:f}return c.apply(b,d.concat(u.call(arguments)))};return e}),q.multiplebgs=function(){return y("background:url(https://),url(https://),red url(https://)"),/(url\s*\(.*?){3}/.test(j.background)},q.borderradius=function(){return E("borderRadius")},q.boxshadow=function(){return E("boxShadow")},q.textshadow=function(){return b.createElement("div").style.textShadow===""},q.cssgradients=function(){var a="background-image:",b="gradient(linear,left top,right bottom,from(#9f9),to(white));",c="linear-gradient(left top,#9f9, white);";return y((a+"-webkit- ".split(" ").join(b+a)+m.join(c+a)).slice(0,-a.length)),B(j.backgroundImage,"gradient")},q.csstransitions=function(){return E("transition")};for(var F in q)x(q,F)&&(v=F.toLowerCase(),e[v]=q[F](),t.push((e[v]?"":"no-")+v));return e.addTest=function(a,b){if(typeof a=="object")for(var d in a)x(a,d)&&e.addTest(d,a[d]);else{a=a.toLowerCase();if(e[a]!==c)return e;b=typeof b=="function"?b():b,typeof f!="undefined"&&f&&(g.className+=" "+(b?"":"no-")+a),e[a]=b}return e},y(""),i=k=null,function(a,b){function k(a,b){var c=a.createElement("p"),d=a.getElementsByTagName("head")[0]||a.documentElement;return c.innerHTML="x<style>"+b+"</style>",d.insertBefore(c.lastChild,d.firstChild)}function l(){var a=r.elements;return typeof a=="string"?a.split(" "):a}function m(a){var b=i[a[g]];return b||(b={},h++,a[g]=h,i[h]=b),b}function n(a,c,f){c||(c=b);if(j)return c.createElement(a);f||(f=m(c));var g;return f.cache[a]?g=f.cache[a].cloneNode():e.test(a)?g=(f.cache[a]=f.createElem(a)).cloneNode():g=f.createElem(a),g.canHaveChildren&&!d.test(a)?f.frag.appendChild(g):g}function o(a,c){a||(a=b);if(j)return a.createDocumentFragment();c=c||m(a);var d=c.frag.cloneNode(),e=0,f=l(),g=f.length;for(;e<g;e++)d.createElement(f[e]);return d}function p(a,b){b.cache||(b.cache={},b.createElem=a.createElement,b.createFrag=a.createDocumentFragment,b.frag=b.createFrag()),a.createElement=function(c){return r.shivMethods?n(c,a,b):b.createElem(c)},a.createDocumentFragment=Function("h,f","return function(){var n=f.cloneNode(),c=n.createElement;h.shivMethods&&("+l().join().replace(/\w+/g,function(a){return b.createElem(a),b.frag.createElement(a),'c("'+a+'")'})+");return n}")(r,b.frag)}function q(a){a||(a=b);var c=m(a);return r.shivCSS&&!f&&!c.hasCSS&&(c.hasCSS=!!k(a,"article,aside,figcaption,figure,footer,header,hgroup,nav,section{display:block}mark{background:#FF0;color:#000}")),j||p(a,c),a}var c=a.html5||{},d=/^<|^(?:button|map|select|textarea|object|iframe|option|optgroup)$/i,e=/^(?:a|b|code|div|fieldset|h1|h2|h3|h4|h5|h6|i|label|li|ol|p|q|span|strong|style|table|tbody|td|th|tr|ul)$/i,f,g="_html5shiv",h=0,i={},j;(function(){try{var a=b.createElement("a");a.innerHTML="<xyz></xyz>",f="hidden"in a,j=a.childNodes.length==1||function(){b.createElement("a");var a=b.createDocumentFragment();return typeof a.cloneNode=="undefined"||typeof a.createDocumentFragment=="undefined"||typeof a.createElement=="undefined"}()}catch(c){f=!0,j=!0}})();var r={elements:c.elements||"abbr article aside audio bdi canvas data datalist details figcaption figure footer header hgroup mark meter nav output progress section summary time video",shivCSS:c.shivCSS!==!1,supportsUnknownElements:j,shivMethods:c.shivMethods!==!1,type:"default",shivDocument:q,createElement:n,createDocumentFragment:o};a.html5=r,q(b)}(this,b),e._version=d,e._prefixes=m,e._domPrefixes=p,e._cssomPrefixes=o,e.testProp=function(a){return C([a])},e.testAllProps=E,g.className=g.className.replace(/(^|\s)no-js(\s|$)/,"$1$2")+(f?" js "+t.join(" "):""),e}(this,this.document),function(a,b,c){function d(a){return"[object Function]"==o.call(a)}function e(a){return"string"==typeof a}function f(){}function g(a){return!a||"loaded"==a||"complete"==a||"uninitialized"==a}function h(){var a=p.shift();q=1,a?a.t?m(function(){("c"==a.t?B.injectCss:B.injectJs)(a.s,0,a.a,a.x,a.e,1)},0):(a(),h()):q=0}function i(a,c,d,e,f,i,j){function k(b){if(!o&&g(l.readyState)&&(u.r=o=1,!q&&h(),l.onload=l.onreadystatechange=null,b)){"img"!=a&&m(function(){t.removeChild(l)},50);for(var d in y[c])y[c].hasOwnProperty(d)&&y[c][d].onload()}}var j=j||B.errorTimeout,l=b.createElement(a),o=0,r=0,u={t:d,s:c,e:f,a:i,x:j};1===y[c]&&(r=1,y[c]=[]),"object"==a?l.data=c:(l.src=c,l.type=a),l.width=l.height="0",l.onerror=l.onload=l.onreadystatechange=function(){k.call(this,r)},p.splice(e,0,u),"img"!=a&&(r||2===y[c]?(t.insertBefore(l,s?null:n),m(k,j)):y[c].push(l))}function j(a,b,c,d,f){return q=0,b=b||"j",e(a)?i("c"==b?v:u,a,b,this.i++,c,d,f):(p.splice(this.i++,0,a),1==p.length&&h()),this}function k(){var a=B;return a.loader={load:j,i:0},a}var l=b.documentElement,m=a.setTimeout,n=b.getElementsByTagName("script")[0],o={}.toString,p=[],q=0,r="MozAppearance"in l.style,s=r&&!!b.createRange().compareNode,t=s?l:n.parentNode,l=a.opera&&"[object Opera]"==o.call(a.opera),l=!!b.attachEvent&&!l,u=r?"object":l?"script":"img",v=l?"script":u,w=Array.isArray||function(a){return"[object Array]"==o.call(a)},x=[],y={},z={timeout:function(a,b){return b.length&&(a.timeout=b[0]),a}},A,B;B=function(a){function b(a){var a=a.split("!"),b=x.length,c=a.pop(),d=a.length,c={url:c,origUrl:c,prefixes:a},e,f,g;for(f=0;f<d;f++)g=a[f].split("="),(e=z[g.shift()])&&(c=e(c,g));for(f=0;f<b;f++)c=x[f](c);return c}function g(a,e,f,g,h){var i=b(a),j=i.autoCallback;i.url.split(".").pop().split("?").shift(),i.bypass||(e&&(e=d(e)?e:e[a]||e[g]||e[a.split("/").pop().split("?")[0]]),i.instead?i.instead(a,e,f,g,h):(y[i.url]?i.noexec=!0:y[i.url]=1,f.load(i.url,i.forceCSS||!i.forceJS&&"css"==i.url.split(".").pop().split("?").shift()?"c":c,i.noexec,i.attrs,i.timeout),(d(e)||d(j))&&f.load(function(){k(),e&&e(i.origUrl,h,g),j&&j(i.origUrl,h,g),y[i.url]=2})))}function h(a,b){function c(a,c){if(a){if(e(a))c||(j=function(){var a=[].slice.call(arguments);k.apply(this,a),l()}),g(a,j,b,0,h);else if(Object(a)===a)for(n in m=function(){var b=0,c;for(c in a)a.hasOwnProperty(c)&&b++;return b}(),a)a.hasOwnProperty(n)&&(!c&&!--m&&(d(j)?j=function(){var a=[].slice.call(arguments);k.apply(this,a),l()}:j[n]=function(a){return function(){var b=[].slice.call(arguments);a&&a.apply(this,b),l()}}(k[n])),g(a[n],j,b,n,h))}else!c&&l()}var h=!!a.test,i=a.load||a.both,j=a.callback||f,k=j,l=a.complete||f,m,n;c(h?a.yep:a.nope,!!i),i&&c(i)}var i,j,l=this.yepnope.loader;if(e(a))g(a,0,l,0);else if(w(a))for(i=0;i<a.length;i++)j=a[i],e(j)?g(j,0,l,0):w(j)?B(j):Object(j)===j&&h(j,l);else Object(a)===a&&h(a,l)},B.addPrefix=function(a,b){z[a]=b},B.addFilter=function(a){x.push(a)},B.errorTimeout=1e4,null==b.readyState&&b.addEventListener&&(b.readyState="loading",b.addEventListener("DOMContentLoaded",A=function(){b.removeEventListener("DOMContentLoaded",A,0),b.readyState="complete"},0)),a.yepnope=k(),a.yepnope.executeStack=h,a.yepnope.injectJs=function(a,c,d,e,i,j){var k=b.createElement("script"),l,o,e=e||B.errorTimeout;k.src=a;for(o in d)k.setAttribute(o,d[o]);c=j?h:c||f,k.onreadystatechange=k.onload=function(){!l&&g(k.readyState)&&(l=1,c(),k.onload=k.onreadystatechange=null)},m(function(){l||(l=1,c(1))},e),i?k.onload():n.parentNode.insertBefore(k,n)},a.yepnope.injectCss=function(a,c,d,e,g,i){var e=b.createElement("link"),j,c=i?h:c||f;e.href=a,e.rel="stylesheet",e.type="text/css";for(j in d)e.setAttribute(j,d[j]);g||(n.parentNode.insertBefore(e,n),m(c,0))}}(this,document),Modernizr.load=function(){yepnope.apply(window,[].slice.call(arguments,0))};
(function(a,b){var c="hidden",d="border-box",e='<textarea style="position:absolute; top:-9999px; left:-9999px; right:auto; bottom:auto; -moz-box-sizing:content-box; -webkit-box-sizing:content-box; box-sizing:content-box; word-wrap:break-word; height:0 !important; min-height:0 !important; overflow:hidden">',f=["fontFamily","fontSize","fontWeight","fontStyle","letterSpacing","textTransform","wordSpacing","textIndent"],g="oninput",h="onpropertychange",i=a(e)[0];i.setAttribute(g,"return"),a.isFunction(i[g])||h in i?a.fn.autosize=function(b){return this.each(function(){function r(){var a,b;n||(n=!0,k.value=i.value,k.style.overflowY=i.style.overflowY,k.style.width=j.css("width"),k.scrollTop=0,k.scrollTop=9e4,a=k.scrollTop,b=c,a>m?(a=m,b="scroll"):a<l&&(a=l),i.style.overflowY=b,i.style.height=a+q+"px",setTimeout(function(){n=!1},1))}var i=this,j=a(i),k,l=j.height(),m=parseInt(j.css("maxHeight"),10),n,o=f.length,p,q=0;if(j.css("box-sizing")===d||j.css("-moz-box-sizing")===d||j.css("-webkit-box-sizing")===d)q=j.outerHeight()-j.height();if(j.data("mirror")||j.data("ismirror"))return;k=a(e).data("ismirror",!0).addClass(b||"autosizejs")[0],p=j.css("resize")==="none"?"none":"horizontal",j.data("mirror",a(k)).css({overflow:c,overflowY:c,wordWrap:"break-word",resize:p}),m=m&&m>0?m:9e4;while(o--)k.style[f[o]]=j.css(f[o]);a("body").append(k),h in i?g in i?i[g]=i.onkeyup=r:i[h]=r:i[g]=r,a(window).resize(r),j.bind("autosize",r),r()})}:a.fn.autosize=function(){return this}})(jQuery);
/**
* HTML5 placeholder polyfill
* @requires jQuery - tested with 1.6.2 but might as well work with older versions
* 
* code: https://github.com/ginader/HTML5-placeholder-polyfill
* please report issues at: https://github.com/ginader/HTML5-placeholder-polyfill/issues
*
* Copyright (c) 2012 Dirk Ginader (ginader.de)
* Dual licensed under the MIT and GPL licenses:
* http://www.opensource.org/licenses/mit-license.php
* http://www.gnu.org/licenses/gpl.html
*
* Version: 2.0
* 
* History:
* * 1.0 initial release
* * 1.1 added support for multiline placeholders in textareas
* * 1.2 Allow label to wrap the input element by noah https://github.com/ginader/HTML5-placeholder-polyfill/pull/1
* * 1.3 New option to read placeholder to Screenreaders. Turned on by default
* * 1.4 made placeholder more rubust to allow labels being offscreen + added minified version of the 3rd party libs
* * 1.5 emptying the native placeholder to prevent double rendering in Browsers with partial support
* * 1.6 optional reformat when a textarea is being resized - requires http://benalman.com/projects/jquery-resize-plugin/
* * 1.7 feature detection is now included in the polyfill so you can simply include it without the need for Modernizr
* * 1.8 replacing the HTML5 Boilerplate .visuallyhidden technique with one that still allows the placeholder to be rendered
* * 1.8.1 bugfix for implicit labels
* * 1.9 New option "hideOnFocus" which, if set to false will mimic the behavior of mobile safari and chrome (remove label when typed instead of onfocus)
* * 1.9.1 added reformat event on window resize
* * 1.9.2 more flexible way to "fix" labels that are hidden using clip() thanks to grahambates: https://github.com/ginader/HTML5-placeholder-polyfill/issues/12
* * 2.0 new easier configuration technique and new options forceApply and AutoInit and support for setters and getters
*
* Modificações:
* - Remoção do width e offset na função positionPlaceholder;
* - No init do plugin: adicionada uma variável com o encapsulador do input (.controls); o placeholder se anexa ao .controls e placeholder.click.
*/


(function($) {
    var debug = true,
        animId;
    function showPlaceholderIfEmpty(input,options) {
        if( $.trim(input.val()) === '' ){
            input.data('placeholder').removeClass(options.hideClass);
        }else{
            input.data('placeholder').addClass(options.hideClass);
        }
    }
    function hidePlaceholder(input,options){
        input.data('placeholder').addClass(options.hideClass);
    }
    function positionPlaceholder(placeholder,input){
        var ta  = input.is('textarea');
        placeholder.css({
            height : input.innerHeight()-6,
            lineHeight : input.css('line-height'),
            whiteSpace : ta ? 'normal' : 'nowrap',
            overflow : 'hidden'
        });
    }
    function startFilledCheckChange(input,options){
        var val = input.val();
        (function checkloop(){
            animId = requestAnimationFrame(checkloop);
            if(input.val() != val){
                hidePlaceholder(input,options);
                stopCheckChange();
                startEmptiedCheckChange(input,options);
            }
        })();
    }
    function startEmptiedCheckChange(input,options){
        var val = input.val();
        (function checkloop(){
            animId = requestAnimationFrame(checkloop);
            showPlaceholderIfEmpty(input,options);
        })();
    }
    function stopCheckChange(){
        cancelAnimationFrame(animId);
    }
    function log(msg){
        if(debug && window.console && window.console.log){
            window.console.log(msg);
        }
    }

    $.fn.placeHolder = function(config) {
        log('init placeHolder');
        var o = this;
        var l = $(this).length;
        this.options = $.extend({
            className: 'placeholder', // css class that is used to style the placeholder
            visibleToScreenreaders : true, // expose the placeholder text to screenreaders or not
            visibleToScreenreadersHideClass : 'placeholder-hide-except-screenreader', // css class is used to visually hide the placeholder
            visibleToNoneHideClass : 'placeholder-hide', // css class used to hide the placeholder for all
            hideOnFocus : false, // either hide the placeholder on focus or on type
            removeLabelClass : 'visuallyhidden', // remove this class from a label (to fix hidden labels)
            hiddenOverrideClass : 'visuallyhidden-with-placeholder', // replace the label above with this class
            forceHiddenOverride : true, // allow the replace of the removeLabelClass with hiddenOverrideClass or not
            forceApply : false, // apply the polyfill even for browser with native support
            autoInit : true // init automatically or not
        }, config);
        this.options.hideClass = this.options.visibleToScreenreaders ? this.options.visibleToScreenreadersHideClass : this.options.visibleToNoneHideClass;
        return $(this).each(function(index) {
            var input = $(this),
                controls = input.parent(),
                text = input.attr('placeholder'),
                id = input.attr('id'),
                label,placeholder,titleNeeded;
            label = input.closest('label')[0];
            input.attr('placeholder','');
            if(!label && !id){
                log('the input element with the placeholder needs an id!');
                return;
            }
            label = label || $('label[for="'+id+'"]');
            if(!label){
                log('the input element with the placeholder needs a label!');
                return;
            }
            
            if($(label).hasClass(o.options.removeLabelClass)){
                $(label).removeClass(o.options.removeLabelClass)
                        .addClass(o.options.hiddenOverrideClass);
            }
            // todo: allow rerun by checking if span already exists instead of adding it blindly
            placeholder = $('<span class="'+o.options.className+'">'+text+'</span>').appendTo(controls);
            if (!input.is(':disabled')) {
                placeholder.on('click', function() {
                    hidePlaceholder(input,o.options);
                    input.focus();
                })
            }
            titleNeeded = (placeholder.width() > input.width());
            if(titleNeeded){
                placeholder.attr('title',text);
            }
            positionPlaceholder(placeholder,input);
            input.data('placeholder',placeholder);
            placeholder.data('input',placeholder);
            placeholder.click(function(){
                $(this).data('input').focus();
            });
            input.focusin(function() {
                if(!o.options.hideOnFocus && window.requestAnimationFrame){
                    startFilledCheckChange(input,o.options);
                }else{
                    hidePlaceholder(input,o.options);
                }
            });
            input.focusout(function(){
                showPlaceholderIfEmpty($(this),o.options);
                if(!o.options.hideOnFocus && window.cancelAnimationFrame){
                    stopCheckChange();
                }
            });
            showPlaceholderIfEmpty(input,o.options);

            // reformat on window resize and optional reformat on font resize - requires: http://www.tomdeater.com/jquery/onfontresize/
            $(document).bind("fontresize resize", function(){
                positionPlaceholder(placeholder,input);
            });

            // optional reformat when a textarea is being resized - requires http://benalman.com/projects/jquery-resize-plugin/
            if($.event.special.resize){
                $("textarea").bind("resize", function(e){
                    positionPlaceholder(placeholder,input);
                });
            }else{
                // we simply disable the resizeablilty of textareas when we can't react on them resizing
                $("textarea").css('resize','none');
            }

            if(index >= l-1){
                $.attrHooks.placeholder = {
                    get: function(elem) {
                        if (elem.nodeName.toLowerCase() == 'input' || elem.nodeName.toLowerCase() == 'textarea') {
                            return $( $(elem).data('placeholder') ).text();
                        }else{
                            return undefined;
                        }
                    },
                    set: function(elem, value){
                        return $( $(elem).data('placeholder') ).text(value);
                    }
                };
            }
        });

    

    };
    $(function(){
        var config = window.placeHolderConfig || {};
        if(config.autoInit === false){
            log('placeholder:abort because autoInit is off');
            return
        }
        if('placeholder' in $('<input>')[0] && !config.forceApply){ // don't run the polyfill when the browser has native support
            log('placeholder:abort because browser has native support');
            return;
        }
        $('input[placeholder], textarea[placeholder]').placeHolder(config);
    });
})(jQuery);
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

    "use strict";


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

  "use strict";


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

  "use strict";


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
      .on('click.dropdown.data-api', clearMenus)
    $('body')
      .on('click.dropdown', '.dropdown form', function (e) { e.stopPropagation() })
      .on('click.dropdown.data-api'  , toggle, Dropdown.prototype.toggle)
      .on('keydown.dropdown.data-api', toggle + ', [role=menu]' , Dropdown.prototype.keydown)
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

  "use strict";


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

  "use strict";


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

  "use strict";


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

    // Adiciona a classe indicativa de controle em foco.
    focusLabel: function(options) {
      var settings = $.extend({
        // Classe adicionada quando o controle está me foco.
        controlFocusedClass: 'control-focused'
        // Classe que identifica o container do controle.
      , controlGroupClass: 'control-group'
      }, options)

      $(this).parents('.' + settings.controlGroupClass).addClass(settings.controlFocusedClass)
    },

    // Remove a classe indicativa de controle em foco.
    removeFocusLabel: function(options) {
      var settings = $.extend({
        // Classe adicionada quando o controle está me foco.
        controlFocusedClass: 'control-focused'
        // Classe que identifica o container do controle.
      , controlGroupClass: 'control-group'
      }, options)

      $(this).parents('.' + settings.controlGroupClass).removeClass(settings.controlFocusedClass)
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
      , controlFile: 'control-file'
      , wrapper: 'control-file-wrapper'
      }, options)

      return this.each(function() {
        var $input = $(this).css({
            'opacity': 0
          })
          , inputVal = $input.val()
          , $wrapper = $(document.createElement('div')).addClass(settings.wrapper)
          , $controlFile = $(document.createElement('div')).addClass(settings.controlFile)
          , $button = $(document.createElement('button')).addClass(settings.buttonDefault).text(settings.buttonText).attr('type', 'button')
          , $filePath = $(document.createElement('span')).addClass(settings.filePath).text($input.data('legend') || settings.filePathText)

        $input.wrap($wrapper)
        $controlFile.append($button).append($filePath).insertAfter($input)

        // No FF, se um arquivo for escolhido e der refresh, o input mantém o valor.
        if (inputVal !== '') {
          $filePath.text(inputVal)
        }

        if (!$.browser.msie) {
          // Repassa o clique pro input file.
          $button.on('click', function(e) {
            $input.trigger('click')
          })
        } else {
          // No IE, põe o input file original na frente.
          $input.css({
            'position': 'absolute',
            'width': $button.width(),
            'height': $button.height(),
            'z-index': 2
          })
        }

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
  // Contador de caracteres.
  var characterCounterSelector = 'input[type="text"][maxlength], input[type="password"][maxlength], textarea[maxlength]'
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

  var focusInputSelectors = 'input[type="text"], input[type="password"], input[type="file"], textarea, select';
  $(document)
    .on('focus', focusInputSelectors, function(e) {
      $(this).reduForm('focusLabel')
    })
    .on('blur', focusInputSelectors, function(e) {
      $(this).reduForm('removeFocusLabel')
    })

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

  $('textarea[rows]').reduForm('resizeByRows')

  $('input[type="file"]').reduForm('styleInputFile')

  // Plugins.

  $('.controls textarea').autosize()

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

    // Expande/colapsa o dropdown.
    // Esconde a legenda, notificações e mostra a lista de disciplinas.
    toggleDropdown: function(options) {
      var settings = $.extend({}, $.fn.reduList.defaults, options)

      var $dropdown = $(this)
        , $listMixItem = $dropdown.closest("." + settings.classes.listMixItem)
        , $listMixHeaderLegend = $listMixItem.find("." +
          settings.classes.listMixHeaderLegend)
        , $listMixBody = $listMixItem.find("." + settings.classes.listMixBody)
        , $listMixInfoClass = $listMixItem.find("." +
          settings.classes.listMixInfo)

      if ($listMixItem.hasClass(settings.classes.openState)) {
        $listMixHeaderLegend.css("visibility", "visible")
      } else {
        $listMixHeaderLegend.css("visibility", "hidden")
      }

      $listMixInfoClass.toggle()
      $listMixItem.toggleClass(settings.classes.openState)
      $listMixBody.toggle(150, "swing")

      return $dropdown
    },

    init: function(options) {

    }
  }

  $.fn.reduList = function(method) {
    if (methods[method]) {
      return methods[method].apply(this, Array.prototype.slice.call(arguments,
        1))
    } else if (typeof method === "object" || !method) {
      return methods.init.apply(this, arguments)
    } else {
      $.error("O método " + method + " não existe em jQuery.reduList")
    }
  }

  $.fn.reduList.defaults = {
    classes: {
      listMixItem: "list-mix-item"
    , listMixHeaderLegend: "list-mix-header .legend"
    , listMixBody: "list-mix-body"
    , listMixInfo: "list-mix-info"
    , openState: "open"
    }
  }

  $(function() {
    $(document).on("click", ".list-mix .button-dropdown:not(.button-disabled)",
      function(e) {
      $(this).reduList("toggleDropdown")
    })
  })

}) (window.jQuery)
$(function() {
  //Desabilita href dos links com estilo de botão, quando no estado desabilidado.
  $(".button-disabled").live("click", function(e) {
    e.preventDefault()
  });
});
!(function($) {

  "use strict";

  var methods = {

    // Altera o estado de seleção da linha do checkbox.
    toggleState: function(options) {
      var settings = $.extend({}, $.fn.reduTables.defaults, options)

      var $checkbox = $(this)
        , $row = $checkbox.closest("tr")
        , $form = $checkbox.closest(settings.selectors.form)

      $row.toggleClass(settings.classes.checkboxSelected)
      $form.trigger("verifySubmit")

      return $checkbox
    }

    // Verifica se o botão de submissão deve ser ativado ou não.
  , verifySubmit: function(options) {
    var settings = $.extend({}, $.fn.reduTables.defaults, options)

    var $form = $(this)
      , $submit = $form.find('input[type="submit"]')
      , $checkboxes = $form.find('input[type="checkbox"]')

    $checkboxes.each(function() {
      var $checkbox = $(this)

      // Se o checkbox foi selecionado, abilita o submit.
      if ($checkbox.is(":checked")) {
        $submit.removeAttr("disabled")
        return false
      } else {
        // Se foi o último a ser desmarcado, desabilita o submit.
        if ($checkboxes.filter(":checked").length === 0) {
          $submit.attr("disabled", "disabled")
        }
      }
    })

    return $form
  }

  , init: function(options) {

    }
  }

  $.fn.reduTables = function(method) {
    if (methods[method]) {
      return methods[method].apply(this,
        Array.prototype.slice.call(arguments, 1))
    } else if (typeof method === "object" || !method) {
      return methods.init.apply(this, arguments)
    } else {
      $.error("O método " + method + " não existe em jQuery.reduTables")
    }
  }

  $.fn.reduTables.defaults = {
    classes: {
      checkboxSelected: "table-checkbox-selected"
    }
  , selectors: {
      form: ".form-checklist"
    }
  }

  $(function() {
    var checkboxSelector = $.fn.reduTables.defaults.selectors.form +
        ' td input[type="checkbox"]'
      , $submit = $($.fn.reduTables.defaults.selectors.form +
        ' input[type="submit"]').attr("disabled", "disabled")
      , enableSubmit = false

    $(document)
      .on("change", checkboxSelector, function(e) {
        $(this).reduTables("toggleState")
      })
      .on("verifySubmit", $.fn.reduTables.defaults.selectors.form,
        function(e) {
        $(this).reduTables("verifySubmit")
      })

    // FF caches os checkboxes selecionados após o page refresh.
    $(checkboxSelector).filter(":checked").each(function() {
      $(this).reduTables("toggleState")
      enableSubmit = true
    })

    if (enableSubmit) {
      $submit.removeAttr("disabled")
    }
  })

}) (window.jQuery)
!(function($) {

  'use strict';

  var settings = {
    originalInput: 'control-autocomplete-input'
  , tokenInputPrefix: 'token-input-'
  , triggerInviteByMail: 'inviteByMail.reduAutocomplete'
  , dropdown: 'control-autocomplete-dropdown'
  , name: 'control-autocomplete-name'
  , mail: 'control-autocomplete-mail legend'
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
      , wasVisible
      , isMaxHeight = true

    wasVisible = methods.displayHidden($modal)

    // O novo tamanho do corpo é: tamanho atual + (altura visível do navegador - espaçamento inferior - topo do modal - altura do modal)
    var newHeight = $modalBody.height() + $(window).height() - (settings.verticalMargin * 2) - $modal.height() + "px"

    var innerHeight = $modalBody[0].scrollHeight - (parseInt($modalBody.css('padding-top'), 10) + parseInt($modalBody.css('padding-bottom'), 10))

    if (innerHeight <= parseInt(newHeight, 10)) {
      newHeight = innerHeight
      isMaxHeight = false
    }

    $modalBody.css('max-height', newHeight)
    $modalBody.css('height', newHeight)

    if (isMaxHeight) {
      $modal.css('top', settings.verticalMargin)
    }

    if (!wasVisible) {
      methods.displayVisible($modal)
    }
  }

    // Preenche verticalmente a janela modal.
  , fillHeight: function(options) {
      var settings = $.extend({
          // Margem inferior.
          verticalMargin: 20
        }, options)

      return this.each(function() {
        var $modal = $(this)
        $modal.on('fitContent.redu', function(e) {
          methods.fitContent($modal, settings)
        })
        $modal.trigger('fitContent.redu')
      })
    }

    // Ajusta a largura do modal para se adequar a largura do conteúdo interno.
    // Caso a largura do conteúdo interno seja maior que a largura visível do navegador, extende o modal horizontalmente para acomodar a máxima largura visível.
  , fillHorizontal: function(options) {
    var settings = $.extend({
        // Margens laterais.
        horizontalMargin: 20
      }, options)

    return this.each(function() {
      var $modal = $(this)
        , maxWidth = $(window).width() - 2 * settings.horizontalMargin

      $modal.css('left', 0)

      var modalWidth = $modal.outerWidth()

      if (modalWidth <= maxWidth) {
        maxWidth = modalWidth
      }

      $modal.css('marginLeft', (-1) * (maxWidth / 2))
      $modal.css('width', maxWidth)

      $modal.css('left', '50%')
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
  $('.modal-fill-horizontal').reduModal('fillHorizontal')

  // Abre uma modal caso seu id esteja na URL.
  var modalId = /#[a-zA-Z\-_\d]*/.exec(document.URL)
  if (modalId !== null) {
    var $modal = $(modalId[0])
    $modal.length !== 0 && $modal.hasClass("modal") && $modal.modal("show")
  }
})
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
    .on('ajax:before', '[data-remote="true"]', function(xhr, settings) {
      $(this).reduSpinners('ajaxBefore')
    })
    .on('ajax:complete', '[data-remote="true"]', function(xhr, status) {
      $(this).reduSpinners('ajaxComplete')
    })
})

!function ($) {

  "use strict";


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
$(function() {
  var settings = {
    // Engloba todo o botão dropdown e formulário de login.
    buttonSignInWrapper: ".header-button-sign-in"
    // O botão dropdown.
  , buttonDropdown: ".dropdown-toggle"
    // O campo de login (logicamente deve ser o primeiro).
  , inputLogin: "input:text:first"
  }

  // Foca no primeiro campo (de login) quando o botão dropdown "Entrar no Redu" é aberto.
  $("body").on("click", settings.buttonSignInWrapper + " " + settings.buttonDropdown, function() {
    setTimeout(function() {
      $(settings.buttonSignInWrapper).find(settings.inputLogin).focus()
    }, 100)
  })
})
;






$(document).ajaxComplete(function() {
  $(".tooltip").remove();
  $('[rel="tooltip"]').tooltip();
});
/*jslint browser: true, eqeqeq: true, bitwise: true, newcap: true, immed: true, regexp: false */

/**
LazyLoad makes it easy and painless to lazily load one or more external
JavaScript or CSS files on demand either during or after the rendering of a web
page.

Supported browsers include Firefox 2+, IE6+, Safari 3+ (including Mobile
Safari), Google Chrome, and Opera 9+. Other browsers may or may not work and
are not officially supported.

Visit https://github.com/rgrove/lazyload/ for more info.

Copyright (c) 2011 Ryan Grove <ryan@wonko.com>
All rights reserved.

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the 'Software'), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
the Software, and to permit persons to whom the Software is furnished to do so,
subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

@module lazyload
@class LazyLoad
@static
@version 2.0.2 (2011-04-17)
*/


LazyLoad = (function (doc) {
  // -- Private Variables ------------------------------------------------------

  // User agent and feature test information.
  var env,

  // Reference to the <head> element (populated lazily).
  head,

  // Requests currently in progress, if any.
  pending = {},

  // Number of times we've polled to check whether a pending stylesheet has
  // finished loading. If this gets too high, we're probably stalled.
  pollCount = 0,

  // Queued requests.
  queue = {css: [], js: []},

  // Reference to the browser's list of stylesheets.
  styleSheets = doc.styleSheets;

  // -- Private Methods --------------------------------------------------------

  /**
  Creates and returns an HTML element with the specified name and attributes.

  @method createNode
  @param {String} name element name
  @param {Object} attrs name/value mapping of element attributes
  @return {HTMLElement}
  @private
  */
  function createNode(name, attrs) {
    var node = doc.createElement(name), attr;

    for (attr in attrs) {
      if (attrs.hasOwnProperty(attr)) {
        node.setAttribute(attr, attrs[attr]);
      }
    }

    return node;
  }

  /**
  Called when the current pending resource of the specified type has finished
  loading. Executes the associated callback (if any) and loads the next
  resource in the queue.

  @method finish
  @param {String} type resource type ('css' or 'js')
  @private
  */
  function finish(type) {
    var p = pending[type],
        callback,
        urls;

    if (p) {
      callback = p.callback;
      urls     = p.urls;

      urls.shift();
      pollCount = 0;

      // If this is the last of the pending URLs, execute the callback and
      // start the next request in the queue (if any).
      if (!urls.length) {
        callback && callback.call(p.context, p.obj);
        pending[type] = null;
        queue[type].length && load(type);
      }
    }
  }

  /**
  Populates the <code>env</code> variable with user agent and feature test
  information.

  @method getEnv
  @private
  */
  function getEnv() {
    // No need to run again if already populated.
    if (env) { return; }

    var ua = navigator.userAgent;

    env = {
      // True if this browser supports disabling async mode on dynamically
      // created script nodes. See
      // http://wiki.whatwg.org/wiki/Dynamic_Script_Execution_Order
      async: doc.createElement('script').async === true
    };

    (env.webkit = /AppleWebKit\//.test(ua))
      || (env.ie = /MSIE/.test(ua))
      || (env.opera = /Opera/.test(ua))
      || (env.gecko = /Gecko\//.test(ua))
      || (env.unknown = true);
  }

  /**
  Loads the specified resources, or the next resource of the specified type
  in the queue if no resources are specified. If a resource of the specified
  type is already being loaded, the new request will be queued until the
  first request has been finished.

  When an array of resource URLs is specified, those URLs will be loaded in
  parallel if it is possible to do so while preserving execution order. All
  browsers support parallel loading of CSS, but only Firefox and Opera
  support parallel loading of scripts. In other browsers, scripts will be
  queued and loaded one at a time to ensure correct execution order.

  @method load
  @param {String} type resource type ('css' or 'js')
  @param {String|Array} urls (optional) URL or array of URLs to load
  @param {Function} callback (optional) callback function to execute when the
    resource is loaded
  @param {Object} obj (optional) object to pass to the callback function
  @param {Object} context (optional) if provided, the callback function will
    be executed in this object's context
  @private
  */
  function load(type, urls, callback, obj, context) {
    var _finish = function () { finish(type); },
        isCSS   = type === 'css',
        i, len, node, p, pendingUrls, url;

    getEnv();

    if (urls) {
      // If urls is a string, wrap it in an array. Otherwise assume it's an
      // array and create a copy of it so modifications won't be made to the
      // original.
      urls = typeof urls === 'string' ? [urls] : urls.concat();

      // Create a request object for each URL. If multiple URLs are specified,
      // the callback will only be executed after all URLs have been loaded.
      //
      // Sadly, Firefox and Opera are the only browsers capable of loading
      // scripts in parallel while preserving execution order. In all other
      // browsers, scripts must be loaded sequentially.
      //
      // All browsers respect CSS specificity based on the order of the link
      // elements in the DOM, regardless of the order in which the stylesheets
      // are actually downloaded.
      if (isCSS || env.async || env.gecko || env.opera) {
        // Load in parallel.
        queue[type].push({
          urls    : urls,
          callback: callback,
          obj     : obj,
          context : context
        });
      } else {
        // Load sequentially.
        for (i = 0, len = urls.length; i < len; ++i) {
          queue[type].push({
            urls    : [urls[i]],
            callback: i === len - 1 ? callback : null, // callback is only added to the last URL
            obj     : obj,
            context : context
          });
        }
      }
    }

    // If a previous load request of this type is currently in progress, we'll
    // wait our turn. Otherwise, grab the next item in the queue.
    if (pending[type] || !(p = pending[type] = queue[type].shift())) {
      return;
    }

    head || (head = doc.head || doc.getElementsByTagName('head')[0]);
    pendingUrls = p.urls;

    for (i = 0, len = pendingUrls.length; i < len; ++i) {
      url = pendingUrls[i];

      if (isCSS) {
          node = env.gecko ? createNode('style') : createNode('link', {
            href: url,
            rel : 'stylesheet'
          });
      } else {
        node = createNode('script', {src: url});
        node.async = false;
      }

      node.className = 'lazyload';
      node.setAttribute('charset', 'utf-8');

      if (env.ie && !isCSS) {
        node.onreadystatechange = function () {
          if (/loaded|complete/.test(node.readyState)) {
            node.onreadystatechange = null;
            _finish();
          }
        };
      } else if (isCSS && (env.gecko || env.webkit)) {
        // Gecko and WebKit don't support the onload event on link nodes.
        if (env.webkit) {
          // In WebKit, we can poll for changes to document.styleSheets to
          // figure out when stylesheets have loaded.
          p.urls[i] = node.href; // resolve relative URLs (or polling won't work)
          pollWebKit();
        } else {
          // In Gecko, we can import the requested URL into a <style> node and
          // poll for the existence of node.sheet.cssRules. Props to Zach
          // Leatherman for calling my attention to this technique.
          node.innerHTML = '@import "' + url + '";';
          pollGecko(node);
        }
      } else {
        node.onload = node.onerror = _finish;
      }

      head.appendChild(node);
    }
  }

  /**
  Begins polling to determine when the specified stylesheet has finished loading
  in Gecko. Polling stops when all pending stylesheets have loaded or after 10
  seconds (to prevent stalls).

  Thanks to Zach Leatherman for calling my attention to the @import-based
  cross-domain technique used here, and to Oleg Slobodskoi for an earlier
  same-domain implementation. See Zach's blog for more details:
  http://www.zachleat.com/web/2010/07/29/load-css-dynamically/

  @method pollGecko
  @param {HTMLElement} node Style node to poll.
  @private
  */
  function pollGecko(node) {
    try {
      node.sheet.cssRules;
    } catch (ex) {
      // An exception means the stylesheet is still loading.
      pollCount += 1;

      if (pollCount < 200) {
        setTimeout(function () { pollGecko(node); }, 50);
      } else {
        // We've been polling for 10 seconds and nothing's happened. Stop
        // polling and finish the pending requests to avoid blocking further
        // requests.
        finish('css');
      }

      return;
    }

    // If we get here, the stylesheet has loaded.
    finish('css');
  }

  /**
  Begins polling to determine when pending stylesheets have finished loading
  in WebKit. Polling stops when all pending stylesheets have loaded or after 10
  seconds (to prevent stalls).

  @method pollWebKit
  @private
  */
  function pollWebKit() {
    var css = pending.css, i;

    if (css) {
      i = styleSheets.length;

      // Look for a stylesheet matching the pending URL.
      while (--i >= 0) {
        if (styleSheets[i].href === css.urls[0]) {
          finish('css');
          break;
        }
      }

      pollCount += 1;

      if (css) {
        if (pollCount < 200) {
          setTimeout(pollWebKit, 50);
        } else {
          // We've been polling for 10 seconds and nothing's happened, which may
          // indicate that the stylesheet has been removed from the document
          // before it had a chance to load. Stop polling and finish the pending
          // request to prevent blocking further requests.
          finish('css');
        }
      }
    }
  }

  return {

    /**
    Requests the specified CSS URL or URLs and executes the specified
    callback (if any) when they have finished loading. If an array of URLs is
    specified, the stylesheets will be loaded in parallel and the callback
    will be executed after all stylesheets have finished loading.

    @method css
    @param {String|Array} urls CSS URL or array of CSS URLs to load
    @param {Function} callback (optional) callback function to execute when
      the specified stylesheets are loaded
    @param {Object} obj (optional) object to pass to the callback function
    @param {Object} context (optional) if provided, the callback function
      will be executed in this object's context
    @static
    */
    css: function (urls, callback, obj, context) {
      load('css', urls, callback, obj, context);
    },

    /**
    Requests the specified JavaScript URL or URLs and executes the specified
    callback (if any) when they have finished loading. If an array of URLs is
    specified and the browser supports it, the scripts will be loaded in
    parallel and the callback will be executed after all scripts have
    finished loading.

    Currently, only Firefox and Opera support parallel loading of scripts while
    preserving execution order. In other browsers, scripts will be
    queued and loaded one at a time to ensure correct execution order.

    @method js
    @param {String|Array} urls JS URL or array of JS URLs to load
    @param {Function} callback (optional) callback function to execute when
      the specified scripts are loaded
    @param {Object} obj (optional) object to pass to the callback function
    @param {Object} context (optional) if provided, the callback function
      will be executed in this object's context
    @static
    */
    js: function (urls, callback, obj, context) {
      load('js', urls, callback, obj, context);
    }

  };
})(this.document);

$(document).ready(function(){
    $.fn.removeLazyAssets = function(options){
      return this.each(function(){
          for(var i in options.paths) {
            var $this = $(this);
            $this.find("script[src='" + options.paths[i] + "'], link[href='" + options.paths[i] + "']", "head").remove();
          }
      });
    };
});


/* SWFObject v2.1 <http://code.google.com/p/swfobject/>
	Copyright (c) 2007-2008 Geoff Stearns, Michael Williams, and Bobby van der Sluis
	This software is released under the MIT License <http://www.opensource.org/licenses/mit-license.php>
*/

var swfobject=function(){var b="undefined",Q="object",n="Shockwave Flash",p="ShockwaveFlash.ShockwaveFlash",P="application/x-shockwave-flash",m="SWFObjectExprInst",j=window,K=document,T=navigator,o=[],N=[],i=[],d=[],J,Z=null,M=null,l=null,e=false,A=false;var h=function(){var v=typeof K.getElementById!=b&&typeof K.getElementsByTagName!=b&&typeof K.createElement!=b,AC=[0,0,0],x=null;if(typeof T.plugins!=b&&typeof T.plugins[n]==Q){x=T.plugins[n].description;if(x&&!(typeof T.mimeTypes!=b&&T.mimeTypes[P]&&!T.mimeTypes[P].enabledPlugin)){x=x.replace(/^.*\s+(\S+\s+\S+$)/,"$1");AC[0]=parseInt(x.replace(/^(.*)\..*$/,"$1"),10);AC[1]=parseInt(x.replace(/^.*\.(.*)\s.*$/,"$1"),10);AC[2]=/r/.test(x)?parseInt(x.replace(/^.*r(.*)$/,"$1"),10):0}}else{if(typeof j.ActiveXObject!=b){var y=null,AB=false;try{y=new ActiveXObject(p+".7")}catch(t){try{y=new ActiveXObject(p+".6");AC=[6,0,21];y.AllowScriptAccess="always"}catch(t){if(AC[0]==6){AB=true}}if(!AB){try{y=new ActiveXObject(p)}catch(t){}}}if(!AB&&y){try{x=y.GetVariable("$version");if(x){x=x.split(" ")[1].split(",");AC=[parseInt(x[0],10),parseInt(x[1],10),parseInt(x[2],10)]}}catch(t){}}}}var AD=T.userAgent.toLowerCase(),r=T.platform.toLowerCase(),AA=/webkit/.test(AD)?parseFloat(AD.replace(/^.*webkit\/(\d+(\.\d+)?).*$/,"$1")):false,q=false,z=r?/win/.test(r):/win/.test(AD),w=r?/mac/.test(r):/mac/.test(AD);/*@cc_on q=true;@if(@_win32)z=true;@elif(@_mac)w=true;@end@*/return{w3cdom:v,pv:AC,webkit:AA,ie:q,win:z,mac:w}}();var L=function(){if(!h.w3cdom){return }f(H);if(h.ie&&h.win){try{K.write("<script id=__ie_ondomload defer=true src=//:><\/script>");J=C("__ie_ondomload");if(J){I(J,"onreadystatechange",S)}}catch(q){}}if(h.webkit&&typeof K.readyState!=b){Z=setInterval(function(){if(/loaded|complete/.test(K.readyState)){E()}},10)}if(typeof K.addEventListener!=b){K.addEventListener("DOMContentLoaded",E,null)}R(E)}();function S(){if(J.readyState=="complete"){J.parentNode.removeChild(J);E()}}function E(){if(e){return }if(h.ie&&h.win){var v=a("span");try{var u=K.getElementsByTagName("body")[0].appendChild(v);u.parentNode.removeChild(u)}catch(w){return }}e=true;if(Z){clearInterval(Z);Z=null}var q=o.length;for(var r=0;r<q;r++){o[r]()}}function f(q){if(e){q()}else{o[o.length]=q}}function R(r){if(typeof j.addEventListener!=b){j.addEventListener("load",r,false)}else{if(typeof K.addEventListener!=b){K.addEventListener("load",r,false)}else{if(typeof j.attachEvent!=b){I(j,"onload",r)}else{if(typeof j.onload=="function"){var q=j.onload;j.onload=function(){q();r()}}else{j.onload=r}}}}}function H(){var t=N.length;for(var q=0;q<t;q++){var u=N[q].id;if(h.pv[0]>0){var r=C(u);if(r){N[q].width=r.getAttribute("width")?r.getAttribute("width"):"0";N[q].height=r.getAttribute("height")?r.getAttribute("height"):"0";if(c(N[q].swfVersion)){if(h.webkit&&h.webkit<312){Y(r)}W(u,true)}else{if(N[q].expressInstall&&!A&&c("6.0.65")&&(h.win||h.mac)){k(N[q])}else{O(r)}}}}else{W(u,true)}}}function Y(t){var q=t.getElementsByTagName(Q)[0];if(q){var w=a("embed"),y=q.attributes;if(y){var v=y.length;for(var u=0;u<v;u++){if(y[u].nodeName=="DATA"){w.setAttribute("src",y[u].nodeValue)}else{w.setAttribute(y[u].nodeName,y[u].nodeValue)}}}var x=q.childNodes;if(x){var z=x.length;for(var r=0;r<z;r++){if(x[r].nodeType==1&&x[r].nodeName=="PARAM"){w.setAttribute(x[r].getAttribute("name"),x[r].getAttribute("value"))}}}t.parentNode.replaceChild(w,t)}}function k(w){A=true;var u=C(w.id);if(u){if(w.altContentId){var y=C(w.altContentId);if(y){M=y;l=w.altContentId}}else{M=G(u)}if(!(/%$/.test(w.width))&&parseInt(w.width,10)<310){w.width="310"}if(!(/%$/.test(w.height))&&parseInt(w.height,10)<137){w.height="137"}K.title=K.title.slice(0,47)+" - Flash Player Installation";var z=h.ie&&h.win?"ActiveX":"PlugIn",q=K.title,r="MMredirectURL="+j.location+"&MMplayerType="+z+"&MMdoctitle="+q,x=w.id;if(h.ie&&h.win&&u.readyState!=4){var t=a("div");x+="SWFObjectNew";t.setAttribute("id",x);u.parentNode.insertBefore(t,u);u.style.display="none";var v=function(){u.parentNode.removeChild(u)};I(j,"onload",v)}U({data:w.expressInstall,id:m,width:w.width,height:w.height},{flashvars:r},x)}}function O(t){if(h.ie&&h.win&&t.readyState!=4){var r=a("div");t.parentNode.insertBefore(r,t);r.parentNode.replaceChild(G(t),r);t.style.display="none";var q=function(){t.parentNode.removeChild(t)};I(j,"onload",q)}else{t.parentNode.replaceChild(G(t),t)}}function G(v){var u=a("div");if(h.win&&h.ie){u.innerHTML=v.innerHTML}else{var r=v.getElementsByTagName(Q)[0];if(r){var w=r.childNodes;if(w){var q=w.length;for(var t=0;t<q;t++){if(!(w[t].nodeType==1&&w[t].nodeName=="PARAM")&&!(w[t].nodeType==8)){u.appendChild(w[t].cloneNode(true))}}}}}return u}function U(AG,AE,t){var q,v=C(t);if(v){if(typeof AG.id==b){AG.id=t}if(h.ie&&h.win){var AF="";for(var AB in AG){if(AG[AB]!=Object.prototype[AB]){if(AB.toLowerCase()=="data"){AE.movie=AG[AB]}else{if(AB.toLowerCase()=="styleclass"){AF+=' class="'+AG[AB]+'"'}else{if(AB.toLowerCase()!="classid"){AF+=" "+AB+'="'+AG[AB]+'"'}}}}}var AD="";for(var AA in AE){if(AE[AA]!=Object.prototype[AA]){AD+='<param name="'+AA+'" value="'+AE[AA]+'" />'}}v.outerHTML='<object classid="clsid:D27CDB6E-AE6D-11cf-96B8-444553540000"'+AF+">"+AD+"</object>";i[i.length]=AG.id;q=C(AG.id)}else{if(h.webkit&&h.webkit<312){var AC=a("embed");AC.setAttribute("type",P);for(var z in AG){if(AG[z]!=Object.prototype[z]){if(z.toLowerCase()=="data"){AC.setAttribute("src",AG[z])}else{if(z.toLowerCase()=="styleclass"){AC.setAttribute("class",AG[z])}else{if(z.toLowerCase()!="classid"){AC.setAttribute(z,AG[z])}}}}}for(var y in AE){if(AE[y]!=Object.prototype[y]){if(y.toLowerCase()!="movie"){AC.setAttribute(y,AE[y])}}}v.parentNode.replaceChild(AC,v);q=AC}else{var u=a(Q);u.setAttribute("type",P);for(var x in AG){if(AG[x]!=Object.prototype[x]){if(x.toLowerCase()=="styleclass"){u.setAttribute("class",AG[x])}else{if(x.toLowerCase()!="classid"){u.setAttribute(x,AG[x])}}}}for(var w in AE){if(AE[w]!=Object.prototype[w]&&w.toLowerCase()!="movie"){F(u,w,AE[w])}}v.parentNode.replaceChild(u,v);q=u}}}return q}function F(t,q,r){var u=a("param");u.setAttribute("name",q);u.setAttribute("value",r);t.appendChild(u)}function X(r){var q=C(r);if(q&&(q.nodeName=="OBJECT"||q.nodeName=="EMBED")){if(h.ie&&h.win){if(q.readyState==4){B(r)}else{j.attachEvent("onload",function(){B(r)})}}else{q.parentNode.removeChild(q)}}}function B(t){var r=C(t);if(r){for(var q in r){if(typeof r[q]=="function"){r[q]=null}}r.parentNode.removeChild(r)}}function C(t){var q=null;try{q=K.getElementById(t)}catch(r){}return q}function a(q){return K.createElement(q)}function I(t,q,r){t.attachEvent(q,r);d[d.length]=[t,q,r]}function c(t){var r=h.pv,q=t.split(".");q[0]=parseInt(q[0],10);q[1]=parseInt(q[1],10)||0;q[2]=parseInt(q[2],10)||0;return(r[0]>q[0]||(r[0]==q[0]&&r[1]>q[1])||(r[0]==q[0]&&r[1]==q[1]&&r[2]>=q[2]))?true:false}function V(v,r){if(h.ie&&h.mac){return }var u=K.getElementsByTagName("head")[0],t=a("style");t.setAttribute("type","text/css");t.setAttribute("media","screen");if(!(h.ie&&h.win)&&typeof K.createTextNode!=b){t.appendChild(K.createTextNode(v+" {"+r+"}"))}u.appendChild(t);if(h.ie&&h.win&&typeof K.styleSheets!=b&&K.styleSheets.length>0){var q=K.styleSheets[K.styleSheets.length-1];if(typeof q.addRule==Q){q.addRule(v,r)}}}function W(t,q){var r=q?"visible":"hidden";if(e&&C(t)){C(t).style.visibility=r}else{V("#"+t,"visibility:"+r)}}function g(s){var r=/[\\\"<>\.;]/;var q=r.exec(s)!=null;return q?encodeURIComponent(s):s}var D=function(){if(h.ie&&h.win){window.attachEvent("onunload",function(){var w=d.length;for(var v=0;v<w;v++){d[v][0].detachEvent(d[v][1],d[v][2])}var t=i.length;for(var u=0;u<t;u++){X(i[u])}for(var r in h){h[r]=null}h=null;for(var q in swfobject){swfobject[q]=null}swfobject=null})}}();return{registerObject:function(u,q,t){if(!h.w3cdom||!u||!q){return }var r={};r.id=u;r.swfVersion=q;r.expressInstall=t?t:false;N[N.length]=r;W(u,false)},getObjectById:function(v){var q=null;if(h.w3cdom){var t=C(v);if(t){var u=t.getElementsByTagName(Q)[0];if(!u||(u&&typeof t.SetVariable!=b)){q=t}else{if(typeof u.SetVariable!=b){q=u}}}}return q},embedSWF:function(x,AE,AB,AD,q,w,r,z,AC){if(!h.w3cdom||!x||!AE||!AB||!AD||!q){return }AB+="";AD+="";if(c(q)){W(AE,false);var AA={};if(AC&&typeof AC===Q){for(var v in AC){if(AC[v]!=Object.prototype[v]){AA[v]=AC[v]}}}AA.data=x;AA.width=AB;AA.height=AD;var y={};if(z&&typeof z===Q){for(var u in z){if(z[u]!=Object.prototype[u]){y[u]=z[u]}}}if(r&&typeof r===Q){for(var t in r){if(r[t]!=Object.prototype[t]){if(typeof y.flashvars!=b){y.flashvars+="&"+t+"="+r[t]}else{y.flashvars=t+"="+r[t]}}}}f(function(){U(AA,y,AE);if(AA.id==AE){W(AE,true)}})}else{if(w&&!A&&c("6.0.65")&&(h.win||h.mac)){A=true;W(AE,false);f(function(){var AF={};AF.id=AF.altContentId=AE;AF.width=AB;AF.height=AD;AF.expressInstall=w;k(AF)})}}},getFlashPlayerVersion:function(){return{major:h.pv[0],minor:h.pv[1],release:h.pv[2]}},hasFlashPlayerVersion:c,createSWF:function(t,r,q){if(h.w3cdom){return U(t,r,q)}else{return undefined}},removeSWF:function(q){if(h.w3cdom){X(q)}},createCSS:function(r,q){if(h.w3cdom){V(r,q)}},addDomLoadEvent:f,addLoadEvent:R,getQueryParamValue:function(v){var u=K.location.search||K.location.hash;if(v==null){return g(u)}if(u){var t=u.substring(1).split("&");for(var r=0;r<t.length;r++){if(t[r].substring(0,t[r].indexOf("="))==v){return g(t[r].substring((t[r].indexOf("=")+1)))}}}return""},expressInstallCallback:function(){if(A&&M){var q=C(m);if(q){q.parentNode.replaceChild(M,q);if(l){W(l,true);if(h.ie&&h.win){M.style.display="block"}}M=null;l=null;A=false}}}}}();
/*
 * Verifies the browser name and version.
 * http://www.javascripter.net/faq/browserv.htm (modified by Redu)
 */

$.browserInfos = function(){
  var nVer = navigator.appVersion;
  var nAgt = navigator.userAgent;
  var browserName = navigator.appName;
  var fullVersion = ''+parseFloat(navigator.appVersion);
  var majorVersion = parseInt(navigator.appVersion,10);
  var nameOffset,verOffset,ix;

  // In Opera, the true version is after "Opera" or after "Version"
  if ((verOffset=nAgt.indexOf("Opera"))!=-1) {
    browserName = "Opera";
    fullVersion = nAgt.substring(verOffset+6);
    if ((verOffset=nAgt.indexOf("Version"))!=-1)
      fullVersion = nAgt.substring(verOffset+8);
  }
  // In MSIE, the true version is after "MSIE" in userAgent
  else if ((verOffset=nAgt.indexOf("MSIE"))!=-1) {
    browserName = "Microsoft Internet Explorer";
    fullVersion = nAgt.substring(verOffset+5);
  }
  // In Chrome, the true version is after "Chrome"
  else if ((verOffset=nAgt.indexOf("Chrome"))!=-1) {
    browserName = "Google Chrome";
    fullVersion = nAgt.substring(verOffset+7);
  }
  // In Safari, the true version is after "Safari" or after "Version"
  else if ((verOffset=nAgt.indexOf("Safari"))!=-1) {
    browserName = "Safari";
    fullVersion = nAgt.substring(verOffset+7);
    if ((verOffset=nAgt.indexOf("Version"))!=-1)
      fullVersion = nAgt.substring(verOffset+8);
  }
  // In Firefox, the true version is after "Firefox"
  else if ((verOffset=nAgt.indexOf("Firefox"))!=-1) {
    browserName = "Mozilla Firefox";
    fullVersion = nAgt.substring(verOffset+8);
  }
  // In most other browsers, "name/version" is at the end of userAgent
  else if ( (nameOffset=nAgt.lastIndexOf(' ')+1) < (verOffset=nAgt.lastIndexOf('/')) )
  {
    browserName = nAgt.substring(nameOffset,verOffset);
    fullVersion = nAgt.substring(verOffset+1);
    if (browserName.toLowerCase()==browserName.toUpperCase()) {
      browserName = navigator.appName;
    }
  }
  // trim the fullVersion string at semicolon/space if present
  if ((ix=fullVersion.indexOf(';'))!=-1) fullVersion=fullVersion.substring(0,ix);
  if ((ix=fullVersion.indexOf(' '))!=-1) fullVersion=fullVersion.substring(0,ix);
  majorVersion = parseInt(''+fullVersion,10);
  if (isNaN(majorVersion)) {
    fullVersion = ''+parseFloat(navigator.appVersion);
    majorVersion = parseInt(navigator.appVersion,10);
  }

  infos = {
    browserName : browserName,
    version : parseFloat(fullVersion.slice(0, fullVersion.indexOf(".")+2)),
    isChrome : function(){
      return browserName == "Google Chrome";
    },
    isFirefox : function(){
      return browserName == "Mozilla Firefox";
    },
    isIE : function(){
      return browserName == "Microsoft Internet Explorer";
    },
    isOpera : function(){
      return browserName == "Opera";
    },
    isSafari : function(){
      return browserName == "Safari";
    }
  };
  return infos;
}
;
/*jslint browser: true */ /*global jQuery: true */

/**
 * jQuery Cookie plugin
 *
 * Copyright (c) 2010 Klaus Hartl (stilbuero.de)
 * Dual licensed under the MIT and GPL licenses:
 * http://www.opensource.org/licenses/mit-license.php
 * http://www.gnu.org/licenses/gpl.html
 *
 */

// TODO JsDoc

/**
 * Create a cookie with the given key and value and other optional parameters.
 *
 * @example $.cookie('the_cookie', 'the_value');
 * @desc Set the value of a cookie.
 * @example $.cookie('the_cookie', 'the_value', { expires: 7, path: '/', domain: 'jquery.com', secure: true });
 * @desc Create a cookie with all available options.
 * @example $.cookie('the_cookie', 'the_value');
 * @desc Create a session cookie.
 * @example $.cookie('the_cookie', null);
 * @desc Delete a cookie by passing null as value. Keep in mind that you have to use the same path and domain
 *       used when the cookie was set.
 *
 * @param String key The key of the cookie.
 * @param String value The value of the cookie.
 * @param Object options An object literal containing key/value pairs to provide optional cookie attributes.
 * @option Number|Date expires Either an integer specifying the expiration date from now on in days or a Date object.
 *                             If a negative value is specified (e.g. a date in the past), the cookie will be deleted.
 *                             If set to null or omitted, the cookie will be a session cookie and will not be retained
 *                             when the the browser exits.
 * @option String path The value of the path atribute of the cookie (default: path of page that created the cookie).
 * @option String domain The value of the domain attribute of the cookie (default: domain of page that created the cookie).
 * @option Boolean secure If true, the secure attribute of the cookie will be set and the cookie transmission will
 *                        require a secure protocol (like HTTPS).
 * @type undefined
 *
 * @name $.cookie
 * @cat Plugins/Cookie
 * @author Klaus Hartl/klaus.hartl@stilbuero.de
 */

/**
 * Get the value of a cookie with the given key.
 *
 * @example $.cookie('the_cookie');
 * @desc Get the value of a cookie.
 *
 * @param String key The key of the cookie.
 * @return The value of the cookie.
 * @type String
 *
 * @name $.cookie
 * @cat Plugins/Cookie
 * @author Klaus Hartl/klaus.hartl@stilbuero.de
 */

jQuery.cookie = function (key, value, options) {

    // key and at least value given, set cookie...
    if (arguments.length > 1 && String(value) !== "[object Object]") {
        options = jQuery.extend({}, options);

        if (value === null || value === undefined) {
            options.expires = -1;
        }

        if (typeof options.expires === 'number') {
            var days = options.expires, t = options.expires = new Date();
            t.setDate(t.getDate() + days);
        }

        value = String(value);

        return (document.cookie = [
            encodeURIComponent(key), '=',
            options.raw ? value : encodeURIComponent(value),
            options.expires ? '; expires=' + options.expires.toUTCString() : '', // use expires attribute, max-age is not supported by IE
            options.path ? '; path=' + options.path : '',
            options.domain ? '; domain=' + options.domain : '',
            options.secure ? '; secure' : ''
        ].join(''));
    }

    // key and possibly options given, get cookie...
    options = value || {};
    var result, decode = options.raw ? function (s) { return s; } : decodeURIComponent;
    return (result = new RegExp('(?:^|; )' + encodeURIComponent(key) + '=([^;]*)').exec(document.cookie)) ? decode(result[1]) : null;
};
jQuery(function(){
    $.verifyCompatibleBrowser();
});

/* Verifica se o browser é compatível e esconde o aviso, caso seja. */
$.verifyCompatibleBrowser = function(){
  var myBrowser = $.browserInfos();
  var minVersion = 0; // Para o caso de ser um browser não usual

  if (myBrowser.isChrome()) {
    minVersion = 11;
  }else if(myBrowser.isSafari()){
    minVersion = 4;
  }else if(myBrowser.isOpera()){
    minVersion = 11;
  }else if(myBrowser.isFirefox()){
    minVersion = 3.6;
  }else if (myBrowser.isIE()){
    minVersion = 9;
  }

  var warned = $.cookie("boring_browser");
  if(!warned && !(myBrowser.version >= minVersion)){
    $("#outdated-browser").show();
  }

  $("#outdated-browser .close").click(function(){
      $.cookie("boring_browser", true, { path: "/" });
      $("#outdated-browser").fadeOut();
  });
};







