jQuery(function(){
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
});
