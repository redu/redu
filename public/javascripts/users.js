(function($){
    // Esconde a data final de uma experiência
    $.fn.refreshEndDateVisibility = function(){
      return this.each(function(){
          $(this).parents(".edit-form").find(".end-date").hide();
      });
    };

    // Mostra o form de criação, caso nenhuma experiência/educação
    // tenha sido criada. Esconde o form, caso contrário.
    refreshDefaultFormsVisibility = function() {
      var experiences = $("#curriculum .experiences > li");
      if (experiences.find(".field_with_errors").length == 0) {
        if (experiences.length > 0
          && $("#new_experience .field_with_errors").length == 0) {
          $("#new_experience").hide();
          $("#curriculum .new-experience-button").show();
        } else {
          $("#new_experience").show();
          $("#curriculum .new-experience-button").hide();
        }
      }

      var educations = $("#curriculum .educations > li");
      if (educations.find(".field_with_errors").length == 0) {
        if (educations.length > 0
          && $("#new_education .field_with_errors").length == 0) {
          $("#new_education").hide();
          $("#curriculum .new-education-button").show();
        } else {
          $("#new_education").show();
          $("#curriculum .new-education-button").hide();
        }
      }
    };

    // Adiciona um novo campo de rede social
    $.fn.refreshSocialNetwork = function(){
      return this.each(function (){
        $("#new-social-network").hide();
        $('#select-networks .select-network').live("change", function() {
          var $this = $(this);
          if ($this.val() != '') {
            if ($this.parent().nextAll("li").length == 0) {
              $this.next().show();
              var new_id = new Date().getTime();
              var regexp = new RegExp("new_social_networks", "g");
              var new_social_network = $('#new-social-network').html();
              new_social_network = new_social_network.replace(regexp, new_id);
              $("#select-networks > ul").append(new_social_network);
            }
          }
        });
      });
    };

    // Mostra o form correto de criação de Educação
    $.fn.refreshShowCorrectForm = function(){
      var $this = $(this);
      var chosen_type = $this.val();
      $("#new_education form").hide();
      $this.removeClass("higher");
      if (chosen_type == "high_school") {
        $("#new_high_school").show();
      } else if (chosen_type == "higher_education") {
        $this.addClass("higher");
        $("#new_higher_education").show();
        $("#higher_education_kind").refreshShowCorrectFields();
      } else if (chosen_type == "complementary_course") {
        $("#new_complementary_course").show();
      } else if (chosen_type == "event_education") {
        $("#new_event_education").show();
      }
    };

    // Mostra os campos corretos no formulário de Ensino Superior
    $.fn.refreshShowCorrectFields = function() {
      var $this = $(this);
      var higher_kind = $this.val();
      if (higher_kind == "technical" || higher_kind == "degree" ||
        higher_kind == "bachelorship") {
        $this.nextAll(".area").hide();
        $this.nextAll(".course").show();
      } else {
        $this.nextAll(".area").show();
        $this.nextAll(".course").hide();
      }
    };


    jQuery(function(){
        $(".experience-current:checked").refreshEndDateVisibility();
        refreshDefaultFormsVisibility();
        $("#biography").refreshSocialNetwork();
        // Esconde os forms de edição
        $("#curriculum .experiences form").hide();
        $("#curriculum .educations form").hide();
        $(".explanation-sidebar .incomplete-profile .edit").hide();

        $(".experience-current").live("change", function(){
            $("#curriculum .end-date").slideToggle();
        });

        $("#curriculum .new-experience-button").live("click", function(){
            $(this).hide();
            $("#new_experience").slideDown();
            return false;
        });

        $("#curriculum .new-education-button").live("click", function(){
            $(this).hide();
            $("#new_education").slideToggle();
            return false;
        });

        // Mostra o form de edição e esconde o item de Experiência
        $("#curriculum .edit-experience").click( function(){
            $experiences = $("#curriculum .experiences > li");
            $infos = $(this).parent('.config-experience');
            $experiences.find(".infos").show();
            $experiences.find("form").slideUp();
            $("#new_experience").hide();
            $("#curriculum .new-experience-button").hide();

            $infos = $(this).parents('.infos');
            $infos.slideUp();
            $infos.siblings("form").slideDown();
            return false;
        });

        // Mostra o form de edição e esconde o item de Educação
        $("#curriculum .edit-education").click( function(){
            $educations = $("#curriculum .educations > li");
            $infos = $(this).parent('.config-experience');
            $educations.find(".infos").show();
            $educations.find("form").slideUp();
            $("#new_education").hide();
            $("#curriculum .new-education-button").hide();

            $infos = $(this).parents('.infos');
            $infos.slideUp();
            $infos.siblings("form").slideDown();
            return false;
        });

        $("#curriculum .cancel").click( function(){
            $educations = $("#curriculum .educations > li");
            $infos = $(this).parent('.config-experience');
            $educations.find(".infos").show();
            $educations.find("form").slideUp();
            $("#new_education").slideUp();
            $("#curriculum .new-education-button").show();

            $experiences = $("#curriculum .experiences > li");
            $infos = $(this).parent('.config-experience');
            $experiences.find(".infos").show();
            $experiences.find("form").slideUp();
            $("#new_experience").slideUp();
            $("#curriculum .new-experience-button").show();

            $infos = $(this).parents('.infos');
            $infos.slideUp();
            $infos.siblings("form").slideUp();
            return false;
        });

        $("#education_type").refreshShowCorrectForm();
        $("#education_type").live("change", function() {
            $(this).refreshShowCorrectForm();
        });


        $("#higher_education_kind").refreshShowCorrectFields();
        $("#higher_education_kind").live("change", function() {
            $(this).refreshShowCorrectFields();
        });

        $(document).ajaxComplete(function(){
            refreshDefaultFormsVisibility();
            $(".experience-current:checked").refreshEndDateVisibility();
            $("#biography").refreshSocialNetwork();
            // Esconde os forms de edição
            $("#curriculum .experiences form").hide();
            $("#curriculum .educations form").hide();
            // Esconde link para editar perfil na barra de completude
            $(".explanation-sidebar .incomplete-profile .edit").hide();
            $("#education_type").refreshShowCorrectForm();
            $("#higher_education_kind").refreshShowCorrectFields();
        });
    });
})($);
