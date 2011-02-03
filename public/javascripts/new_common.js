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
