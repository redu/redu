jQuery(function(){
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

    // Responder status
    $("a.reply-status, .cancel", ".statuses").live("click", function(e){
        $(this).parents("ul:first").next(".create-response").slideToggle();
        $(this).parents(".create-response:first").slideToggle();
        e.preventDefault();
    });

    // Esconde as respostas, caso não haja nenhuma
    $(".responses").each(function(){
        var responses = $(this).find("> ol > li");
        if (responses.length == 0) {
          $(this).hide();
        }
    });

    // Apenas mostrar as 3 primeiras respostas e mostrar texto "Ver todos os X comentários"
    $(".responses", ".statuses").each(function(i, obj){
        var quantity = $(this).find("ol > li").length;
        if (quantity >= 3) {
          $(this).find("> ol > li:gt(2)").hide();
          $(this).find(".toggle-statuses .qty").html(quantity);
        } else {
          $(this).find(".toggle-statuses").remove();
        }
    });

    // Mostrar todas as respostas ao clicar em "Ver todos os X comentários"
    $(".toggle-statuses", ".statuses").live("click", function(e){
        $(this).prev().find("> li:hidden").slideDown();
        e.preventDefault();
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

    // Expand de recursos na listagem de módulos
    $(".expand, .unexpand", "#space-subjects .subjects").click(function(){
        $(this).toggleClass("expand");
        $(this).toggleClass("unexpand");
        $(this).parents("li:first").toggleClass("open");
        $(this).next().slideToggle("fast");
    });

    // Mostra status no show de lecture
    $("#resource .student-actions .action-help").click(function(e){
        $(this).parents("li:first").toggleClass("selected");
        $(".statuses-wrapper", "#resource").slideToggle();
        e.preventDefault();
    });

    // Carrega preview do Youtube (new Seminar)
    $('#seminar_external_resource').live("change", function(){
        youtubePreview($('#seminar_external_resource'));
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
    $(".form-common, .form-loader").live('ajax:before', function(){
        $(this).find("input[type=submit]").loadingStart();
    });

    $(".form-common, .form-loader").live('ajax:complete', function(){
        $(this).find("input[type=submit]").loadingComplete();
    });

    $("a[data-remote=true]").live('ajax:before', function(){
        $(this).css('width', $(this).width());
        $(this).addClass("link-loading");
    });

    $("a[data-remote=true]").live('ajax:complete', function(){
        $(this).css('width', 'auto');
        $(this).removeClass("link-loading");
    });

    $.fn.loadingStart = function(){
      return this.each(function(){
          $bt = $(this);
          $bt.addClass("bt-loading");
      });
    };

    $.fn.loadingComplete = function(){
      return this.each(function(){
          $bt = $(this);
          $bt.removeClass("bt-loading");
      });
    };

    $.fn.loadingToggle = function(){
      return this.each(function(){
          $bt = $(this);

          if( $bt.hasClass('bt-loading') ) {
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

/* Carrega o preview do Youtube */
function youtubePreview(textfield){
  regex = /youtube\.com\/watch\?v=([A-Za-z0-9._%-]*)[&\w;=\+_\-]*/;

  id = textfield.val().match(regex)
  if (id != null) {
    youtube_id = id[1];
    url = "http://www.youtube.com/v/" + youtube_id + "&hl=en&fs=1";

    jQuery('#yt_preview_param').attr("value",url);
    jQuery('embed').attr("src",url);
    jQuery('#youtube_preview').show();

  }  else {
    $('#youtube_preview').hide();
  }

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
    youtubePreview($('#seminar_external_resource'));
    $('#seminar_submit').show();
  }

}
