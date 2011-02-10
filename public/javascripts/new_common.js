jQuery(function(){
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

    // Apenas mostrar as 3 primeiras respostas e mostrar texto "Ver todos os X comentários"
    $(".responses", ".statuses").each(function(i, obj){
        $(this).find("> ol > li:gt(2)").hide();
        $(this).find(".toggle-statuses .qty").html($(this).find("ol > li").length);
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
    $("#new_subject .new-resource li").live('hover', function(){
        var explanation = "<strong>" + $(this).html() + "</strong>";
        explanation += $(this).find("a").attr("title");

        $("#new_subject .new-resource .explanation").html(explanation);
    });


});

function limitChars(textclass, limit, infodiv){
  var text = $('.' + textclass).val();
  var textlength = text.length;
  if (textlength > limit) {
    // $('#' + infodiv).html('You cannot write more then ' + limit + ' characters!');
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

