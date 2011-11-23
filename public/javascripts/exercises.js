$(function(){
  $.fn.refreshExercises = function() {
    this.each(function(){
        $(".alternatives li input[type='radio']").live("click", function(){
          $(".alternatives li").removeClass("selected");
          $(this).parent().addClass("selected");
          $(".exercise-nav li a.actual").parent().addClass("question-answered");
        });
    });
  }

  // Aplica nestedFields às questões e alternativas de Exercício
  $.fn.refreshNestedFields = function(){
    var alternativeOptions = {
      containerSelector: ".alternative-container",
      itemSelector: ".alternative-item",
      addSelector: ".alternative-add",
      removeSelector: ".alternative-remove",
      itemTemplateSelector: ".alternative.template",
      newItemIndex: "new_alternative_item",
      afterInsert: function(item) {
        item.refreshForms();
        item.refreshAlternativesNumbering();
        // Adiciona bind que insere nova alternativa
        item.bind("click", function(){
          item.parents(".nested-fields-level-2").nestedFields("insert");
        });
        // Remove da alternativa anterior bind que adiciona alternativa
        var lastAlternatives = item.prevAll(".alternative-item")
        lastAlternatives.unbind("click");
        lastAlternatives.removeClass("disabled");
        lastAlternatives.find(".tip").text("Digite uma alternativa para a questão");
      },
      beforeRemove: function(item) {
          item.hide();
          item.refreshAlternativesNumbering();
      }
    };

    $(this).find(".nested-fields-level-1").nestedFields({
      containerSelector: ".question-container",
      itemSelector: ".question-item",
      addSelector: ".question-add",
      removeSelector: ".question-remove",
      itemTemplateSelector: ".question.template",
      newItemIndex: "new_question_item",
      afterInsert: function(item) {
        // Aplica nestedFields às alternativas da nova questão
        item.find(".nested-fields-level-2").nestedFields(alternativeOptions);

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
    $(this).find('.nested-fields-level-2').nestedFields(alternativeOptions);
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
      // Clica na última alternativa para que as já criadas fiquem do tamanho
      // maior enquanto que apenas a última fica disabled.
      $(this).find(".alternative-container").find(".alternative-item:not([data-new-record='true']):last").click();
    });
  };

  // Deixa apenas uma alternativa marcada como certa
  $("#space-manage .concave-form .question-item .concave-multiple").live("change", function(e){
    $(this).parent().siblings().find(".concave-multiple").attr("checked", false)
  });
  $(document).ready(function(){
    $(document).refreshExercises();
    $(document).refreshNestedFieldsEdition();

    $(document).ajaxComplete(function(){
      $(document).refreshExercises();
      $(document).refreshNestedFieldsEdition();
      });
  });
});
