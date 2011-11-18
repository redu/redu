(function($){
  // Padrão de spinner
  $(".admin-filter-form").live('ajax:before', function(e){
    var $this = $(this);
    var $target = $(e.target);

    if($this.is($target)){
      var $submit = $(this).find("input[type=submit]");
      $submit.loadingStart({ "className" : "concave-loading" });
    }
  });

  $(".admin-filter-form").live('ajax:complete', function(){
    $(this).find("input[type=submit]").loadingComplete({ "className" : "concave-loading" });
  });

  // Atualiza path do curso (slug)
  $("#course_name, #course_path").live('keyup blur', function(e){
    var slugedPath = $(this).slug();
    $("#course_path").val(slugedPath);
    $("#environment-manage .course-path .course-name, #course-manage .course-path .course-name").html(slugedPath);
  });

  // Colorindo tabela de roles
  $.fn.refreshRoleTable = function(){
    return $("#environment-manage .admin-role-table tr:even").addClass("even");
  };

  // Alterna entre o formulário de Youtube e Upload (new Seminar)
  $.fn.refreshFormUpload = function(){
    $("#lecture_lectureable_attributes_external_resource_type_youtube, #lecture_lectureable_attributes_external_resource_type_upload").change(function(){
      $('#youtube_preview, #upload_resource_field, #external_resource_field').toggle();
    });
  }

  // Explicação de tipos de recursos (utilizado na criação de módulo)
  $(".new-resource .resources-types li").live('hover', function(){
    var link = $(this).find("a")
    var text = link.text();
    var explanation = "<strong class='type'>" + text + ":</strong> ";
    explanation += link.attr("title");

    $(".new-resource .resources-types .explanation").html(explanation).show();
    // Evita que o explanation fique com o spinner
    $(".new-resource .resources-types .explanation").find("a").removeClass("link-loading");
  });

  // Adiciona classe selected ao li do recurso clicado
  $("#space-manage .new-resource .resources-types li a").live("click", function(){
    $("#space-manage .new-resource .resources-types li").removeClass("selected");
    $(this).parents("li:first").addClass("selected");
  });

  // Atualiza textarea com o texto contido no CKeditor
  $(".page-form").live("ajax:before", function(){
    for (instance in CKEDITOR.instances){
      var $ckEditor = $("#" + instance);

      // Verifica se o campo ainda se encontra na tela
      if($ckEditor.length === 0) {
        CKEDITOR.remove(CKEDITOR.instances[instance]);
      } else {
        CKEDITOR.instances[instance].updateElement();
      }
    }
  });

  // Ação do botão cancelar (criação de recurso)
  $("#space-manage .new-resource .concave-form .cancel-lecture").live("click", function(e){
    var answer = confirm("As informações inseridas serão perdidas. Deseja continuar?")
    if(answer == true){
      $(this).parents('.new-resource .resource-form').slideUp();
      $("#space-manage .new-resource .resources-types li").removeClass("selected");
    }
    e.preventDefault();
  });

  // Ação do botão cancelar (edição de recurso)
  $("#space-manage .edit-resource .concave-form .cancel-lecture").live("click", function(e){
    var answer = confirm("As informações modificadas serão perdidas. Deseja continuar?")
    if(answer == true){
      $(this).parents(".edit-resource").slideUp();
      var itemId = $(this).parent().parent().attr("id").split("-edition")[0];
      $("#" + itemId).toggleClass("editing");
    }
    e.preventDefault();
  });

  // Mostra o formulário de edição do recurso
  $("#space-manage .resources > li .edit").live("click", function(e){
    var $item = $(this).parent();
    $item.toggleClass("editing");
    var $editionItem = $("#" + $item.attr("id") + "-edition");
    $editionItem.slideToggle();
    $editionItem.find(".question-item:first-child").refreshQuestionsNumbering();
    e.preventDefault();
  });

  // Atualiza a numeração dos recursos
  $.fn.refreshResourcesNumbering = function(){
    var $resources = $(this).find("> li:not(.no-lectures)");
    var qttResources = $resources.length;
    // Atualiza número da próxima aula a ser criada
    $("#lectures_types .resources-types").find(".position").text(qttResources + 1);

    if(qttResources > 0){
      $(this).find("> li.no-lectures").remove();
      // Atualiza o número das aulas na listagem e nos forms de edição
      $resources.each(function(index){
        newPosition = (index + 1);
        $(this).find(".position").text(newPosition + ".");
        itemId = "#" + $(this).attr("id") + "-edition";
        $(formId + ".resource-numbering .position").text(newPosition);
      });
    }else{
      $(this).html($("<li/>", { "class" : "no-lectures", "text" : "Nenhuma aula foi adicionada ainda."}))
    }
  };

  // Pede confirmação do usuário para finalizar o módulo
  $("#subject_submit").live("click", function(e){
    var $openForms = $("form:visible:not([class~='new-subject'])");
    if($openForms.length > 0){
      var answer = confirm("As aulas que não foram adicionadas e/ou salvas serão perdidas. Deseja continuar?")
      if(answer == true){
        $(".new-subject").submit();
      }
    }else{
      $(".new-subject").submit();
    }
    e.preventDefault();
  });

  // Faz o cursor ser uma mão ao arrastar aulas para ordenar
  $(".ui-sortable").live("mousedown mouseup", function(){
    $(this).toggleClass("grabbing");
  });

  // Aplica nestedFields às questões e alternativas de Exercício
  $.fn.refreshNestedFields = function(){
    $(this).find(".nested-fields-level-1").nestedFields({
      containerSelector: ".question-container",
      itemSelector: ".question-item",
      addSelector: ".question-add",
      removeSelector: ".question-remove",
      itemTemplateSelector: ".question.template",
      afterInsert: function(item) {
        // Aplica nestedFields às alternativas da nova questão
        item.find(".nested-fields-level-2").nestedFields({
          containerSelector: ".alternative-container",
          itemSelector: ".alternative-item",
          addSelector: ".alternative-add",
          removeSelector: ".alternative-remove",
          itemTemplateSelector: ".alternative.template",
          afterInsert: function(item) {
            item.refreshForms();
            item.refreshAlternativesNumbering();
          },
          beforeRemove: function(item) {
            item.hide();
            item.refreshAlternativesNumbering();
          }
        });

        // Insere um campo de alternativa para a nova questão
        item.find(".nested-fields-level-2").nestedFields("insert");
        item.refreshForms();
        item.refreshQuestionsNumbering();
        if (item.hasClass("closed")) {
          item.find(".expand").click();
        }
        item.find(".alternative-item").refreshAlternativesNumbering();
      },
      afterRemove: function(item) {
        item.refreshQuestionsNumbering();
      }
    });

    // Aplica nestedFields às alternativas da primeira questão
    $(this).find('.nested-fields-level-2').nestedFields({
      containerSelector: ".alternative-container",
      itemSelector: ".alternative-item",
      addSelector: ".alternative-add",
      removeSelector: ".alternative-remove",
      itemTemplateSelector: ".alternative.template",
      afterInsert: function(item) {
        item.refreshForms();
        item.refreshAlternativesNumbering();
      },
      beforeRemove: function(item) {
        item.hide();
        item.refreshAlternativesNumbering();
      }
    });
  };

  // Expande a questão
  $("#space-manage .concave-form .question-item .summary .expand").live("click", function(){
    $(this).parent().slideToggle();
    var $questionItem = $(this).parents(".question-item");
    $questionItem.toggleClass("closed");
    var $fields = $questionItem.find(".fields");
    $fields.slideToggle();
    $fields.find(".alternative-item:first-child").refreshAlternativesNumbering();
  });

  // Retraí a questão
  $("#space-manage .concave-form .question-item .finalize-edition").live("click", function(e){
    var $questionItem = $(this).parents(".question-item");
    var $fields = $questionItem.find(".fields");
    var $summary = $questionItem.find(".summary");
    $questionItem.toggleClass("closed");
    $fields.slideToggle();
    $questionItem.refreshExerciseSummary();
    $summary.slideToggle();
    e.preventDefault();
  });

  // Atualiza informações no summary
  $.fn.refreshExerciseSummary = function(){
    return this.each(function(){
      var $fields = $(this).find(".fields")
      var $summary = $(this).find(".summary");

      var qttAlternatives = $fields.find(".alternative-container .alternative-item:visible").length;
    $summary.find(".alternatives .qtt").text(qttAlternatives);
    var statement = $fields.find(".question-statement").val();
    if (statement != ""){
      $summary.find(".statement").text(statement);
    }else{
      $summary.find(".statement").text("(Enunciado não informado)");
    }

    var correctAlternative = $fields.find(".concave-multiple:checked").prev().text();
    if (correctAlternative != ""){
      $summary.find(".alternatives .correct").text(correctAlternative);
    }else{
      $summary.find(".alternatives .correct").text("(não marcada)");
    }
    });
  };

  // Atualiza numeração das questões
  $.fn.refreshQuestionsNumbering = function(){
    return this.each(function(){
      var $questions = $(this).parent().find(".question-item:visible");
      $questions.each(function(index){
        $(this).find(".position").text(index + 1);
      });
    });
  };

  // Atualiza letras das alternativas
  $.fn.refreshAlternativesNumbering = function(){
    return this.each(function(){
      var $alternatives = $(this).parent().find(".alternative-item:visible");
      var alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
      $alternatives.each(function(index){
        var letter = alphabet[index];
        $(this).find(".alternative-label").text(letter);
      });
    });
  };

  // Aplica nestedFields a todos os exercícios já criados (edição)
  $.fn.refreshNestedFieldsEdition = function(){
    $("#resources-edition .edit-resource.exercise").each(function(){
      $(this).refreshNestedFields();
    });
  };

  // Deixa apenas uma alternativa marcada como certa
  $("#space-manage .concave-form .question-item .concave-multiple").live("change", function(e){
    $(this).parent().siblings().find(".concave-multiple").attr("checked", false)
  });

  $(document).ready(function(){
    $(document).refreshRoleTable();
    $(document).refreshFormUpload();
    $(document).refreshNestedFieldsEdition();
    $(document).ajaxComplete(function(){
      $(document).refreshRoleTable();
      $(document).refreshFormUpload();
      $(document).refreshNestedFieldsEdition();
    });
  });
})(jQuery);
