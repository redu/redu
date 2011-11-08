$(function(){
  $.fn.refreshExercises = function() {
    this.each(function(){
        $(".alternatives li input[type='radio']").live("click", function(){
          $(".alternatives li").removeClass("selected");
          $(this).parent().addClass("selected");
        });
    });
  }

  $(document).ready(function(){
      $(document).refreshExercises();

      $(document).ajaxComplete(function(){
          $(document).refreshExercises();
      });
  });
});
