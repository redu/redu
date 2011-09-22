jQuery(function(){
    $.fn.refreshStatuses = function(){
      // Esconde as respostas, caso não haja nenhuma
      $(".responses").each(function(){
          var responses = $(this).find("> ol > li");
          if (responses.length <= 3) {
            $(this).find(".toggle-statuses").hide();
          }

          if (responses.length == 0) {
            $(this).hide();
          }
      });

      // Apenas mostrar as 3 primeiras respostas e mostrar texto "Ver todos os X comentários"
      $(".responses", ".statuses").each(function(i, obj){
          var quantity = $(this).find("ol > li").length;
          if (quantity >= 3) {
            if ($(this).find(".toggle-statuses").is(":visible")) {
              $(this).find("> ol > li:gt(2)").hide();
              $(this).find(".toggle-statuses .qty").html(quantity);
            }
          }
      });
    }

    // Responder status
    $("a.reply-status, .cancel", ".statuses").live("click", function(e){
        $(this).parents("ul:first").next(".create-response").slideToggle();
        $(this).parents(".create-response:first").slideToggle();
        e.preventDefault();
    });

    // Mostrar todas as respostas ao clicar em "Ver todos os X comentários"
    $(".toggle-statuses", ".statuses").live("click", function(e){
        $(this).prev().find("> li:hidden").slideDown();
        $(this).hide();
        e.preventDefault();
    });

    $(document).ready(function(){
        $(document).refreshStatuses();

        $(document).ajaxComplete(function(){
            console.log("refresh!");
            $(document).refreshStatuses();
        });
    });


});
