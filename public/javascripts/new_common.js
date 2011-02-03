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

});
