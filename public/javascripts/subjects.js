(function($){
    $.refreshSubjects = function(){
      $("#lecture_lectureable_attributes_external_resource").die();
      $("#lecture_lectureable_attributes_external_resource").ytPreview({ titleField : ".new-resource #lecture_name" });
    }

    $(document).ready(function(){
        $.refreshSubjects();

        $(document).ajaxComplete(function(){
            $.refreshSubjects();
        });
    });
})(jQuery);
