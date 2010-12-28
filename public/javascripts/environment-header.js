$(document).ready(function(){
    $(".dropdown .breadcrumb .spaces").hover(function(){
        $(this).find("ul:first").fadeIn()
        $(this).find("span.arrow-down:first").toggleClass("hover")
        $(this).find("a.current-space:first").animate({ paddingLeft: "10px"}, 100)
      },
      function(){
        $(this).find("ul:first").fadeOut()
        $(this).find("span.arrow-down:first").toggleClass("hover")
        $(this).find("a.current-space:first").animate({ paddingLeft: "0"}, 100)
    })

    $("#create-header .management").click(function(){
        $(".management-dialog").dialog({ width: "450px", title : "O que você deseja gerenciar?" })
        $(".ui-dialog").wrap("<div class=\"cupertino\"></div>")
    })
})
