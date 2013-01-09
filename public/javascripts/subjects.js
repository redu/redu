(function($){
  $(document).ready(function(){
    $.refreshSubjects = function(){
      $("#lecture_lectureable_attributes_external_resource").die();
      $("#lecture_lectureable_attributes_external_resource").ytPreview({ titleField : ".new-resource #lecture_name" });
      // Scroll até o módulo que está sendo visualizado
      $('#space-subjects .subjects .child .lectures:not(:hidden)').scrollToSubject();
    }

    // Define o contexto em que esse método deve ser acionado
    // para que outros links que usam essas classes não tenha
    // comportamento inesperado
    var context = $("#space-subjects .subjects")[0];
    if (context) {
      // Expand de recursos na listagem de módulos
      $(".expand, .subject-name", context).live("click", function(){
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
    };

    $.fn.scrollToSubject = function(){
      return this.each(function(){
        var $this = $(this);
        $('body').animate({
          scrollTop: $this.parent(".child").offset().top - 20
        }, "slow");
      });
    }
    $.refreshSubjects();

    $(document).ajaxComplete(function(){
      $.refreshSubjects();
    });
  });
})(jQuery);
