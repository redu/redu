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
          $("#curriculum .experience .config-new-item").show();
        } else {
          $("#new_experience").show();
          $("#curriculum .experience .config-new-item").hide();
        }
      }

      var educations = $("#curriculum .educations > li");
      if (educations.find(".field_with_errors").length == 0) {
        if (educations.length > 0
          && $("#new_education .field_with_errors").length == 0) {
          $("#new_education").hide();
          $("#curriculum .education .config-new-item").show();
        } else {
          $("#new_education").show();
          $("#curriculum .education .config-new-item").hide();
        }
      }
    };

    removeTitle = function() {
      var experience_title = $('#new_experience').find('.title');
      var education_title = $('#new_education').find('.title');
      var experience_cancel = $('#new_experience .cancel');
      var education_cancel = $('#new_education .cancel');

      if (!$('#curriculum .experiences li').length) {
        $('#new_experience').css('padding-top', 0);
        experience_cancel.hide();
        experience_title.remove();
      }

      if (!$('#curriculum .educations li').length) {
        $('#new_education').css('padding-top', 0);
        education_cancel.hide();
        education_title.remove();
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
        removeTitle();
        $("#biography").refreshSocialNetwork();
        // Esconde os forms de edição
        $("#curriculum .experiences form").hide();
        $("#curriculum .educations form").hide();
        $(".explanation-sidebar .incomplete-profile .edit").hide();

        $(document).on('change', '.experience-current', function(){
            $("#curriculum .end-date").slideToggle(150, 'swing');
        });

        $(document).on('click', '#curriculum .new-experience-button', function(){
            $('#curriculum .experience .config-new-item').hide();
            $('#curriculum .experience .curriculum-buttons .cancel').show();
            $("#new_experience").slideDown(150, 'swing');
            return false;
        });

        $(document).on('click', '#curriculum .new-education-button', function(){
            $('#curriculum .education .config-new-item').hide();
            $('#curriculum .education .curriculum-buttons .cancel').show();
            $("#new_education").slideToggle(150, 'swing');
            return false;
        });

        // Mostra o form de edição e esconde o item de Experiência
        $(document).on('click', '#curriculum .edit-experience', function(){
            $experiences = $("#curriculum .experiences > li");
            $infos = $(this).parent('.config-experience');
            $experiences.find(".infos").show();
            $experiences.find("form").slideUp();
            $("#new_experience").hide();
            $("#curriculum .experience .config-new-item").hide();

            $infos = $(this).parents('.infos');
            $infos.slideUp(150, 'swing');
            $('#curriculum .experience .curriculum-buttons .cancel').show();
            $infos.siblings("form").slideDown(150, 'swing');
            return false;
        });

        // Mostra o form de edição e esconde o item de Educação
        $(document).on('click', '#curriculum .edit-education', function(){
            $educations = $("#curriculum .educations > li");
            $infos = $(this).parent('.config-experience');
            $educations.find(".infos").show();
            $educations.find("form").slideUp();
            $("#new_education").hide();
            $("#curriculum .education .config-new-item").hide();

            $infos = $(this).parents('.infos');
            $infos.slideUp(150, 'swing');
            $('#curriculum .education .curriculum-buttons .cancel').show();
            $infos.siblings("form").slideDown(150, 'swing');
            return false;
        });

        $(document).on('click', '#curriculum .education .cancel', function(){
            $educations = $("#curriculum .educations > li");
            $infos = $(this).parent('.config-experience');
            $educations.find(".infos").show();
            $educations.find("form").slideUp(150, 'swing');
            $("#new_education").slideUp(150, 'swing');
            $("#curriculum .education .config-new-item").show();

            $infos = $(this).parents('.infos');
            $infos.slideUp(150, 'swing');
            $infos.siblings("form").slideUp(150, 'swing');
            return false;
        });

        $(document).on('click', '#curriculum .experience .cancel', function(){
            $experiences = $("#curriculum .experiences > li");
            $infos = $(this).parent('.config-experience');
            $experiences.find(".infos").show();
            $experiences.find("form").slideUp(150, 'swing');
            $("#new_experience").slideUp(150, 'swing');
            $("#curriculum .experience .config-new-item").show();

            $infos = $(this).parents('.infos');
            $infos.slideUp(150, 'swing');
            $infos.siblings("form").slideUp(150, 'swing');
            return false;
        });

        $(document).on('click', '.curriculum-buttons .add-item', function() {
          $('.curriculum-buttons .cancel').hide();
        });

        $("#education_type").refreshShowCorrectForm();
        $(document).on('change', '#education_type', function() {
          $(this).refreshShowCorrectForm();
        });


        $("#higher_education_kind").refreshShowCorrectFields();
        $(document).on('change', '#higher_education_kind', function() {
            $(this).refreshShowCorrectFields();
        });

        $(document).ajaxComplete(function() {
          refreshDefaultFormsVisibility();
          removeTitle();
          $(".experience-current:checked").refreshEndDateVisibility();
          $("#biography").refreshSocialNetwork();
          // Esconde link para editar perfil na barra de completude
          $(".explanation-sidebar .incomplete-profile .edit").hide();
          $("#education_type").refreshShowCorrectForm();
          $("#higher_education_kind").refreshShowCorrectFields();
        });
    });
})($);
