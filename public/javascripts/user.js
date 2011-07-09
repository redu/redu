(function($){
    $.fn.refreshMobileMask = function(){
      return this.each(function(){
          var $this = $(this);
          $this.mask("+99 (99) 9999-9999", { placeholder:" " });
      });
    };

    $.fn.refreshEndDateVisibility = function(){
      return this.each(function(){
          $(this).parent().siblings(".end-date").hide();
      });
    };

    jQuery(function(){
        $("#biography .mobile").refreshMobileMask();
        $(".current-experience #experience_current:checked").refreshEndDateVisibility();
        $("#experience_current").live("change", function(){
            $("#curriculum .end-date").slideToggle();
        });

        $("#curriculum .new-experience-button").live("click", function(){
            $(this).hide();
            $("#new_experience").slideToggle();
            return false;
        });

        $("#curriculum .edit-experience").live("click", function(){
            $experiences = $("#curriculum .experiences > li");
            $experiences.find(".infos").show();
            $experiences.find("form").fadeOut();
            $("#new_experience").hide();
            $("#curriculum .new-experience-button").hide();

            var $infos = $(this).parent();
            $infos.fadeOut();
            $infos.siblings("form").fadeIn();
            return false;
        });

        $(document).ajaxComplete(function(){
            $("#biography .mobile").refreshMobileMask();
            $(".current-experience #experience_current:checked").refreshEndDateVisibility();
        });
    });

})($);
