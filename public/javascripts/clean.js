$(function() {
    $("body").noisy({
        "intensity": 1,
        "size": "400",
        "opacity": 0.079,
        "fallback":"/images/t-noisy.png",
        "monochrome": true
    }).css("background-color", "#e6e6e6");

    // Copiado de application.js:

    /* Spinner em links remotos */
    $("a[data-remote=true]").live('ajax:before', function(){
        $(this).css('width', $(this).width());
        $(this).loadingStart({ "className" : "link-loading" });
    });

    $("a[data-remote=true]").live('ajax:complete', function(){
        $(this).css('width', 'auto');
        $(this).loadingComplete({ "className" : "link-loading" });
    });

    /* Links remotos com estilo de botão */
    $("a[data-remote=true].concave-button, a[data-remote=true].concave-important").live('ajax:before', function(){
      // Remove spinner padrão para links
      $(this).css('width', 'auto');
      $(this).removeClass("link-loading");
      $(this).loadingStart();
    });

    $("a[data-remote=true].concave-button, a[data-remote=true].concave-important").live('ajax:complete', function(){
      $(this).loadingComplete();
    });

    /* Impede que links desabilitados tenham funcionem quando clicados */
    $("a.disabled").live('click', function(e){
      e.preventDefault();
    });

    /* Mostra o spinner e desabilita o elemento */
    $.fn.loadingStart = function(options){
      var config = {
        "className" : "concave-loading",
        "disabledClass" : "disabled"
      }
      $.extend(config, options);

      return this.each(function(){
          $bt = $(this);
          $bt.addClass(config.className);
          $bt.addClass(config.disabledClass);

          if($bt.is("input[type=submit]") || $bt.is("button")){
            $bt.attr("disabled", true)
          }
      });
    };

    /* Esconde o spinner e habilita o elemento */
    $.fn.loadingComplete = function(options){
      var config = {
        "className" : "concave-loading",
        "disabledClass" : "disabled"
      }
      $.extend(config, options);

      return this.each(function(){
          $bt = $(this);
          $bt.removeClass(config.className);
          $bt.removeClass(config.disabledClass);

          if($bt.is("input[type=submit]") || $bt.is("button")){
            $bt.attr("disabled", false)
          }
      });
    };
});
