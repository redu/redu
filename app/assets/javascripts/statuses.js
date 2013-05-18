jQuery(function(){
    $.fn.refreshStatuses = function(){
      // Esconde as respostas, caso não haja nenhuma
      $(".responses").each(function(){
          var $this = $(this);
          var responses = $this.find("> ol > li");
          if (responses.length <= 3) {
            $this.find(".toggle-statuses").hide();
            $this.find(".last-responses").hide();
            $this.find(".border-post:first").hide();
          }

          if (responses.length == 0) {
            $this.hide();
          }
      });

      // Apenas mostrar as respostas mais recentes e mostrar texto
      // "Ver todos os X comentários".
      $(".statuses .responses").each(function(i, obj){
          var quantity = $(this).find("ol > li").length;
          var max = 3;
          if (quantity >= max) {
            if ($(this).find(".toggle-statuses").is(":visible")) {
              var $this = $(this);
              $this.find("> ol > li:lt(" + (quantity - max) + ")").hide();
              $this.find(".toggle-statuses .qty").html(quantity);
            }
          }
      });
    }

    // Responder status
    $("a.reply-status, .cancel", ".statuses").live("click", function(e){
        var $this = $(this);
        var $ul = $this.parents("ul:first");
        $ul.next(".create-response").slideToggle();
        $this.parents(".create-response:first").slideToggle();
        $ul.next(".create-response").find("textarea").focus();
        $ul.next(".create-status").find("textarea:first").val("");
        $this.parents(".create-status").find("textarea:first").val("");
        e.preventDefault();
    });

    // Mostrar todas as respostas ao clicar em "Ver todos os X comentários"
    $(".toggle-statuses", ".statuses").live("click", function(e){
        var $this = $(this);
        $this.prev().find("> li:hidden").slideDown();
        $this.hide();
        $this.siblings(".last-responses").hide();
        $this.siblings("ol").find(".border-post:first").hide();
        e.preventDefault();
    });

    // Mostrar os elementos escondidos do log composto
    $(".show-more").live("click", function(){
        var $container = $(this).parents('.box');
        var newHeight = Math.ceil($container.find("> .grouped-photos li").length / 11) * 40 - 30;
        $container.find('.show-more').hide("fast", function() {
          $container.find(".grouped-photos").animate({ height: ("+=" + newHeight) }, 200);
        });
        return false;
    });

    // Permite ao usuário compartilhar recursos embutidos em suas postagens
    $.refreshEmbeddedSharing = function() {
        $('.create-status').enableEmbedding();
    }

    $(document).ready(function(){
        $(document).refreshStatuses();

        $(document).ajaxComplete(function(){
            $(document).refreshStatuses();
            $.refreshEmbeddedSharing();
        });

        $.refreshEmbeddedSharing();
    });
});
