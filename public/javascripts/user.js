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

    $.fn.refreshSocialNetwork = function(){
      return this.each(function (){
        $("#new-social-network").hide();
        $('#select-networks .select-network').live("change", function() {
          var $this = $(this);
          if ($this.val() != '') {
            if ($this.nextAll(".select-network").length == 0) {
              $this.next().show();
              var new_id = new Date().getTime();
              var regexp = new RegExp("new_social_networks", "g");
              var new_social_network = $('#new-social-network').html();
              new_social_network = new_social_network.replace(regexp, new_id);
              $("#new-social-network").before(new_social_network);
            }
          }
        });
      });
    };

    jQuery(function(){
        $("#biography .mobile").refreshMobileMask();
        $(".current-experience #experience_current:checked").refreshEndDateVisibility();
        $("#biography").refreshSocialNetwork();

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
            $("#biography").refreshSocialNetwork();
        });
    });
})($);
