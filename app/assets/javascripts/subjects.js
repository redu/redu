(function($){
  $(document).ready(function(){
    $.refreshSubjects = function(){
      $("#lecture_lectureable_attributes_external_resource_url").die();
      $("#lecture_lectureable_attributes_external_resource_url").ytPreview({ titleField : ".new-resource #lecture_name" });
    }

    $.refreshSubjects();

    $(document).ajaxComplete(function(){
      $.refreshSubjects();
    });
  });
})(jQuery);
