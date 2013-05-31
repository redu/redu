$(function(){
    $.fn.refreshLectures = function(){
      this.each(function(){
          // Adicionando overlay caso ele não exista
          if($("#lights_dimmed").length == 0) {
            $overlay = $("<div/>", { 'id' : 'lights_dimmed', 'class' : 'clearfix'}).hide();
            $("body").prepend($overlay);
          }else{
            // Garantindo que a luz começará apagada
            $("#lights_dimmed").fadeOut();
          }

          // Luzes
          $("#lights").toggle(
            function(e){
              var docHeight = $(document).height();
              $(".resource-content").css("position", "relative").css("backgroundColor", "white");
              $(".resource-content").addClass("boxshadow-lights");
              $(".statuses-wrapper").css("position", "relative").css("backgroundColor", "white");
              $("#lights_dimmed").css("height", docHeight).fadeIn();
              $(this).html("<span class=\"lights icon-small icon-light-on-lightblue_32_34\"></span>Acender luzes");
              e.preventDefault();
            },
            function(){
              $("#lights_dimmed").fadeOut();
              $(".resource-content").removeClass("boxshadow-lights");
              $(this).html("<span class=\"lights icon-small icon-light-off-lightblue_32_34\"></span>Apagar luzes");
            }
          );

          $(".statuses-wrapper").live("click", function(){
              var docHeight = $(document).height();
              $("#lights_dimmed:visible").css("height", docHeight)
          });

          $("#do_lecture").live("ajax:before ajax:complete", function(){
              $(this).find("label[for='Aula_finalizada']").toggleClass("link-loading");
          });

          // Mostra status no show de lecture
          $("#resource .student-actions .action-help").click(function(e){
              $(this).parents("li:first").toggleClass("selected");
              $(".statuses-wrapper", "#resource").slideToggle();
              $(".statuses-wrapper #new_status #status_text").focus();
              e.preventDefault();
          });
      });
    }

    // Ao clicar em Comentar ir direto para criar status
    $(".student-actions .action-comment").live("click", function(){
      $('html,body').animate({
          scrollTop: $(".lecture-wall-actions").offset().top - 50
        }, "slow");
      var $commentButton = $(".button-comment");

      if (!$commentButton.parent().hasClass("open")) {
        $commentButton.click();
      }
    });

    $("#resource .status-type .type-item").live("click", function(e){
      var $input = $("[name='status\[type\]']","#new_status");
      var data = $(this).find("a").data();

      $(this).siblings().andSelf().toggleClass("selected");
      $input.val(data.type);

      e.preventDefault();
    });


    // Setando o tamanho do iframe do conteúdo da página simples
    $.fn.setIframeHeight = function(){
      $("#page-iframe").load(function(){
          $("#page-iframe").height($("#page-iframe").contents().height());
          $("#page-iframe").contents().each( function(i){
              $(this).find("a").attr('target', '_blank');
          })
      });
    }

    // Scroll os botões de student-actions de acordo com o #resource
    $(document).scroll(function(){
      if ($("#resource").length > 0) {

        var $actions = $(".student-actions");
        var limit = $(window).scrollTop()- $("#resource").offset().top;

        if(limit > -9) {
          if(limit < 490 ){
            $(".student-actions").css({'top' : limit + 'px'});
          }
        } else {
          $(".student-actions").css({'top' : '0px'});
        }
      }
    });

    $(document).ready(function(){
        $(document).refreshLectures();
        $(document).setIframeHeight();

        $(document).ajaxComplete(function(){
          $(document).refreshLectures();
          $(document).setIframeHeight();
        });
    });
});

// Player
var params = {
  'allowfullscreen':    'true',
  'allowscriptaccess':  'always',
  'bgcolor':            '#ffffff'
};

var attributes = {
  'id':                 'player',
  'name':               'player'
};
