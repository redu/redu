jQuery(function(){

    $.verifyCompatibleBrowser();

    // Flash message
    $(".flash-message").parent().next().css("marginTop", "10px");
    $(".flash-message .close-flash").click(function(e){
      $(this).parent().slideToggle();
      $("#content").css("marginTop","20px");
      $("#home").css("marginTop","40px");

      e.preventDefault();
    });

    // Dropdown de usuário
    $("#nav-account").hover(function(){
        $(this).find(".username").toggleClass("hover");
        $(this).find("ul").toggle();
    });

    // Aumentar form de criação de Status
    $("input[type=submit], .cancel, .char-limit", ".inform-my-status").hide();
    $(".inform-my-status textarea").live("focus", function(e){
        $(this).parents("form").find("input[type=submit], .cancel, .char-limit").fadeIn();
    });
    $(".inform-my-status textarea").live("blur", function(e){
        $(this).parents("form").find("input[type=submit], .cancel, .char-limit").fadeOut();
    });

    // Adicionar classe focus a um determinado label quando o seu campo
    // correspondente detectar o evento focus
    $("input[type=text], input[type=password], input[type=radio], input[type=checkbox]","form.highlightable").focus(function(){
        var label_for = $(this).attr("id") || null;

        if(label_for)
          $("label[for=" + label_for + "]").addClass("focus");
    }).blur(function(){
        var label_for = $(this).attr("id") || null;

        if(label_for)
          $("label[for=" + label_for + "]").removeClass("focus");
    });

    // gerador do path do environmet e course
    jQuery.fn.slug = function() {
      var $this = $(this);
      var slugcontent = stripAccent($this.val());
      var slugcontent_hyphens = slugcontent.replace(/\s+/g,'-');
      return slugcontent_hyphens.replace(/[^a-zA-Z0-9\-]/g,'').toLowerCase();
    };

    // Explicação de tipos de recursos (utilizado na criação de módulo)
    $(".new-resource li").live('hover', function(){
        var explanation = "<strong>" + $(this).html() + "</strong>";
        explanation += $(this).find("a").attr("title");

        $(".new-resource .explanation").html(explanation);
        // Evita que o explanation fique com o spinner
        $(".new-resource .explanation").find("a").removeClass("link-loading");
    });

    // Adiciona classe selected ao li do recurso clicado
    $("#new_subject .new-resource li a").live("click", function(){
        $("#new_subject .new-resource li").removeClass("selected");
        $(this).parents("li:first").addClass("selected");
    })

    // Padrão de tabelas
    $("table.common tr:even:not(.invite):not(.message)").addClass("odd");

    // Form com tabelas
    $("#select_all").change(
      function(e){
        var pivot = $(this);

        if(pivot.is(":checked"))
          $("input[type=checkbox].autoCheck").attr('checked', true)
        else
          $("input[type=checkbox].autoCheck").attr('checked', false)

        return true;
      }
    );

    // Filtros da listagem de cursos
    $("#global-courses .filters .filter").each(function(){
        var checkbox = $(this).find("input");

        if(checkbox.is(":checked"))
          $(this).addClass("checked");

    });

    $("#global-courses .filters input[type=checkbox]").change(function(){
        var $wrapper = $(this).parent();
        $wrapper.toggleClass("checked");
    });

    $("#global-courses .filters .checked").each(function(){
        $(this).find("input").attr("checked", true);
    });

    // Itens da listagem de cursos
    $("#global-courses .courses .expand").live("click", function(){
        $(this).toggleClass("unexpand");
        $(this).parents(":first").next().slideToggle();
    });

    // O elemento assume a altura do seu pai
    $(".parent-height").height(function(i, height){
        $(this).height($(this).parent().height());
    });

    // Mostra campo de confirmação de e-mail
    $("#user_email").click(function(){
       $("#user_email_confirmation").slideDown();
       $("#user_email_confirmation").prev().slideDown();
    });

    // Verifica se os dois e-mails são iguais
    $("#user_email_confirmation").blur(function(){
        email_val = $("#user_email").val();
        confirmation_val = $(this).val();

        if (email_val != confirmation_val) {
          $("#user_email_confirmation-error").remove();
          $(this).after("<p id=\"user_email_confirmation-error\" class=\"errorMessageField\">Os e-mails digitados não são iguais.</p>");

        } else {
          $("#user_email_confirmation-error").remove();
        }
    });

    // Tooltips
    $(".tiptip").tipTip();
    $(".form-common").ajaxComplete(function(){
      $(".tiptip").tipTip();
    });

    $(".form-common .tiptip").each(function(){
        var label = $(this).next("label");
        label.prepend($(this));
    });

    $(".tiptip-lite").each(function(){
        // Criando holder e adicionando conteúdo
        var $tip = $("<span class='tiptip question-blue_12_12'/>");
        $tip.attr("title", $(this).attr("title"));
        $tip.tipTip();

        $(this).after($tip);
        $tip.position({
            my: 'left center',
            at: 'right center',
            of: $(this),
            offset: "10px 0",
        });
    });

    // Arquivos
    $("#space-materials .new-folder .button").click(function(e){
        $(this).next(".new-folder-inner").toggle();
        e.preventDefault();
    });

    // Padrão de spinner
    $(".form-common, .form-loader").live('ajax:before', function(e){
        var $this = $(this);
        var $target = $(e.target);

        if($target.is($this)){
          $(this).find("input[type=submit]").loadingStart();
        }
    });

    $(".form-common, .form-loader").live('ajax:complete', function(e){
        var $this = $(this);
        var $target = $(e.target);

        if($target.is($this)){
          $(this).find("input[type=submit]").loadingComplete();
        }
    });

    $("a[data-remote=true]").live('ajax:before', function(){
        $(this).css('width', $(this).width());
        $(this).addClass("link-loading");
    });

    $("a[data-remote=true]").live('ajax:complete', function(){
        $(this).css('width', 'auto');
        $(this).removeClass("link-loading");
    });

    $.fn.loadingStart = function(options){
      var config = {
        "className" : "bt-loading"
      }
      $.extend(config, options);

      return this.each(function(){
          $bt = $(this);
          $bt.addClass(config.className);
      });
    };

    $.fn.loadingComplete = function(options){
      var config = {
        "className" : "bt-loading"
      }
      $.extend(config, options);

      return this.each(function(){
          $bt = $(this);
          $bt.removeClass(config.className);
      });
    };

    $.fn.loadingToggle = function(options){
      var config = {
        "className" : "bt-loading"
      }
      $.extend(config, options);

      return this.each(function(){
          $bt = $(this);

          if( $bt.hasClass(config.className) ) {
            $bt.loadingComplete();
          } else {
            $bt.loadingStart();
          }
      });
    };

});

/* Limita a quantidade de caracteres de um campo */
function limitChars(textclass, limit, infodiv){
  var text = $('.' + textclass).val();
  var textlength = text.length;
  if (textlength > limit) {
    $('.' + textclass).val(text.substr(0, limit));
    return false;
  } else {
    $('.' + infodiv).html(limit - textlength);
    return true;
  }
}

/* Create path */
function stripAccent(str) {
  var rExps = [{ re: /[\xC0-\xC6]/g, ch: 'A' },
    { re: /[\xE0-\xE6]/g, ch: 'a' },
    { re: /[\xC8-\xCB]/g, ch: 'E' },
    { re: /[\xE8-\xEB]/g, ch: 'e' },
    { re: /[\xCC-\xCF]/g, ch: 'I' },
    { re: /[\xEC-\xEF]/g, ch: 'i' },
    { re: /[\xD2-\xD6]/g, ch: 'O' },
    { re: /[\xF2-\xF6]/g, ch: 'o' },
    { re: /[\xD9-\xDC]/g, ch: 'U' },
    { re: /[\xF9-\xFC]/g, ch: 'u' },
    { re: /[\xE7]/g, ch: 'c' },
    { re: /[\xC7]/g, ch: 'C' },
    { re: /[\xD1]/g, ch: 'N' },
    { re: /[\xF1]/g, ch: 'n'}];

  for (var i = 0, len = rExps.length; i < len; i++)
    str = str.replace(rExps[i].re, rExps[i].ch);

  return str;
}

/* Alterna entre o formulário de Youtube e Upload (new Seminar) */
function switchCourseFields(fieldType){
  if (fieldType == 1) {
    $('#upload_resource_field').show();
    $('#external_resource_field').hide();
    $('#youtube_preview').hide();
    $('#seminar_submit').hide();
  } else {
    $('#upload_resource_field').hide();
    $('#external_resource_field').show();
    $('#seminar_submit').show();
  }

}

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
    minVersion = 8;
  }

  var warned = $.cookie("boring_browser");
  if(!warned && !(myBrowser.version >= minVersion &&
    swfobject.hasFlashPlayerVersion("10"))){
    $("#outdated-browser").show();
  }

  $("#outdated-browser .close").click(function(){
      $.cookie("boring_browser", true, { path: "/" });
      $("#outdated-browser").fadeOut();
  });
}

