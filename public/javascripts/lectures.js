$(function(){
    $.fn.refreshLectures = function(){
      this.each(function(){
          $overlay = $("<div/>", { 'id' : 'lights_dimmed', 'class' : 'clearfix'}).hide();
          $("body").prepend($overlay);

          // Luzes
          $("#lights").toggle(function(e){
              var docHeight = $(document).height();

              $(".student-actions").css("position", "relative");
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
          });

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
          scrollTop: $(".create-status textarea.textarea").offset().top
        }, "slow");
      $(".create-status textarea.textarea").focus();
    });

    // Scroll os botões de student-actions de acordo com o #resource
    $(document).scroll(function(){
      if ($("#resource").length > 0) {
        if(($("#resource").offset().top - $(window).scrollTop() < 30)) {
          $(".student-actions").css({'position': 'fixed', 'top':'10px'})
        } else {
          $(".student-actions").css({'position': 'relative'})
        }
      }
    });

    $(document).ready(function(){
        $(document).refreshLectures();

        $(document).ajaxComplete(function(){
          $(document).refreshLectures();
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
