(function($){
    $.refreshSubjects = function(){
      $("#seminar_external_resource").die();
      $("#seminar_external_resource").ytPreview({ titleField : ".yt-title" });
      // Scroll até o módulo que está sendo visualizado
      $('html,body').animate({
        scrollTop: $("#space-subjects .subjects .child .lectures:not(:hidden)").parent().offset().top - 20
      }, "slow");
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
        $.refreshSubjects();

        $(document).ajaxComplete(function(){
            $.refreshSubjects();
        });
    });
})(jQuery);
