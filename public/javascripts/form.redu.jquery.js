(function($){
    $.fn.refreshForms = function(){
      return this.each(function(){
          // Classes de objetos presentes do form
          var $form = $(this);
          var $inputs = $form.find("input[type=text], input[type=password], textarea");
          var $labels = $form.find("label");
          var $multiple = $form.find("input[type=checkbox], input[type=radio]");
          var $fieldsetInline = $form.find("fieldset.inline");
          var $fieldsetLinebreak = $form.find("fieldset.linebreak");
          var $fieldset = $form.find("fieldset:not(.inline)");
          var $files = $form.find("input[type=file]");
          var $select = $form.find("select");
          var $buttons = $form.find("input[type=submit], button, input[type=button]");
          var $separator = $form.find("hr");

          // Cabels
          $labels.addClass("concave-label");

          // Inputs de texto em geral
          $inputs.addClass("concave-input");

          // Arquivosj
          $files.addClass("concave-file");
          /* Estilo de file
          $files.wrap($("<div/>", { "class" : "concave-file-wrapper" })).each(function(){
              var $browse = $("<div/>", { "class" : "browse button" }).text("Procurar");

              $browse.live("click", function(){ $(this).click(); });
              $(this).append($browse);
          });
          */

          // Radios, checkbox e optiosn
          $multiple.addClass("concave-multiple");
          $select.addClass("concave-select");

          // Fieldsets
          $fieldset.addClass("concave-fieldset");
          $fieldset.find("> legend").addClass("concave-fieldset-legend");
          $fieldsetInline.addClass("concave-fieldset-inline");
          $fieldsetLinebreak.find(".concave-multiple:gt(0)").addClass("concave-break");

          // botões
          $buttons.addClass("concave-button");

          // Separadores
          $separator.addClass("concave-separator");

          // Highlight do label
          $inputs.live("focus", function(){
              var id = $(this).attr("id") || null;
              $("[for=" + id + "]").addClass("concave-label-focus");
          }).blur(function(){
              var id = $(this).attr("id") || null;
              $("[for=" + id+ "]").removeClass("concave-label-focus");
          });

          // Padrão de spinner
          $(".concave-form").live('ajax:before', function(e){
              var $this = $(this);
              var $target = $(e.target);

              if($this.is($target)){
                var $submit = $(this).find("input[type=submit]");
                $submit.loadingStart({ "className" : "concave-loading" });
              }
        });

          $(".concave-form").live('ajax:complete', function(){
              $(this).find("input[type=submit]").loadingComplete({ "className" : "concave-loading" });
          });

      });
    };

    $(document).ready(function(){
        $(".concave-form").refreshForms();

        // Para os campos carregados dinâmicamente
        $(document).ajaxComplete(function(){
            $(".concave-form").refreshForms();
        });
    });
})($);
