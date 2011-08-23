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
    $(".expand, .subject-name", "#space-subjects .subjects").live("click", function(){
        var item = $(this).parents("li:first");
        var expand = item.find(".expand");
        expand.toggleClass("icon-expand_down-gray_16_18");
        expand.toggleClass("icon-expand_up-gray_16_18");
        var itemName = item.find("> .name");
        itemName.toggleClass("icon-content-lightblue_32_34-before");
        itemName.toggleClass("icon-subject-lightblue_32_34-before");
        item.find(".lectures").slideToggle("fast");
        return false;
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
