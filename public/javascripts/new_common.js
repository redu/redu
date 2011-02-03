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
    })
});
