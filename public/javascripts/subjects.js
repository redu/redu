(function($){
    $.refreshSubjects = function(){
      $("#seminar_external_resource").die();
      $("#seminar_external_resource").ytPreview({ titleField : ".yt-title" });
    }

    $(document).ready(function(){
        $.refreshSubjects();

        $(document).ajaxComplete(function(){
            $.refreshSubjects();
        });
    });
})(jQuery);
