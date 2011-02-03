jQuery(function(){
    // Dropdown de usuário
    $("#nav-account").hover(function(){
        $(this).find(".username").toggleClass("hover");
        $(this).find("ul").toggle();
    });
});
