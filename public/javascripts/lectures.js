$(function(){
    $.fn.refreshLectures = function(){
      this.each(function(){
          $overlay = $("<div/>", { 'id' : 'lights_dimmed', 'class' : 'clearfix'}).hide();
          $("body").prepend($overlay);

          // Luzes
          $("#lights").toggle(function(e){
              var docHeight = $(document).height();

              $(".student-actions").css("position", "relative");
              $(".stage").css("position", "relative");
              $(".statuses-wrapper").css("position", "relative").css("backgroundColor", "white");
              $("#lights_dimmed").css("height", docHeight).fadeIn();
              $(this).html("Acender luzes");
              e.preventDefault();
            },
            function(){
              $("#lights_dimmed").fadeOut();
              $(this).html("Apagar luzes");
          });

          $(".statuses-wrapper").live("click", function(){
              var docHeight = $(document).height();
              $("#lights_dimmed:visible").css("height", docHeight)
          });

          $("#do_lecture").live("ajax:before ajax:complete", function(){
              $(this).find("label[for='Aula_finalizada']").toggleClass("link-loading");
          });
      });
    }

    // Expand de recursos na listagem de módulos
    $(".expand, .unexpand", "#space-subjects .subjects").live("click", function(){
        $(this).toggleClass("expand");
        $(this).toggleClass("unexpand");
        $(this).parents("li:first").toggleClass("open");
        $(this).next().slideToggle("fast");
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
