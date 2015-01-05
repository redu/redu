$(function(){

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
          item.removeClass("visible");
          item.refreshAlternativesNumbering();
      }
    };

    $("#fechada").click(function(){
      $(this).find(".nested-fields-level-1").nestedFields({

      //if(document.getElementById("fechada").checked){
      
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
          item.find(".alternative-item").refreshAlternativesNumbering();
        },
        afterRemove: function(item) {
          item.removeClass("visible");
          item.refreshQuestionsNumbering();
        }
      //}
      });
    });
  $("#aberta").click(function(){
    $(this).find(".nested-fields-level-1").nestedFields({

      //if(document.getElementById("fechada").checked){
      // $("#fechada").click(function(){
      //   containerSelector: ".question-container",
      //   itemSelector: ".question-item",
      //   addSelector: ".question-add",
      //   removeSelector: ".question-remove",
      //   itemTemplateSelector: ".question.template",
      //   newItemIndex: "new_question_item",
      //   afterInsert: function(item) {
      //     // Aplica nestedFields às alternativas da nova questão
      //     item.find(".nested-fields-level-2").nestedFields(alternativeOptions);

      //     // Insere um campo de alternativa para a nova questão
      //     item.find(".nested-fields-level-2").nestedFields("insert");
      //     item.refreshForms();
      //     item.refreshQuestionsNumbering();
      //     item.find(".alternative-item").refreshAlternativesNumbering();
      //   },
      //   afterRemove: function(item) {
      //     item.removeClass("visible");
      //     item.refreshQuestionsNumbering();
      //   }
      // //}
      // });

      // //if(document.getElementById("aberta").checked){
      // $("#aberta").click(function(){
        containerSelector: ".ar-question-container",
        itemSelector: ".ar-question-item",
        addSelector: ".ar-question-add",
        removeSelector: ".ar-question-remove",
        itemTemplateSelector: ".ar-question.template",
        newItemIndex: "new_ar_question_item",

        afterRemove: function(item) {
          item.removeClass("visible");
          item.refreshArQuestionsNumbering();
        }
      //}
    });

  });

    // Aplica nestedFields às alternativas da primeira questão
    $(this).find('.nested-fields-level-2').nestedFields(alternativeOptions);
  };

  // Expande a questão
  $("#space-manage .concave-form .question-item .summary .expand").live("click", function(){
    $(this).parents(".question-item").expandQuestion();
  });

  // Click do botão finalizar
  $("#space-manage .concave-form .question-item .finalize-edition").live("click", function(e){
    $(this).parents(".question-item").retractQuestion();
    e.preventDefault();
  });

  // Expande a questão
  $.fn.expandQuestion = function(){
    return this.each(function(){
      $(this).find(".summary").slideUp();
      $(this).removeClass("closed");
      var $fields = $(this).find(".fields");
      $fields.slideDown();
      $fields.find(".alternative-item:first-child").refreshAlternativesNumbering();
    });
  };

  // Retrai a questão
  $.fn.retractQuestion = function(){
    return this.each(function(){
      var $fields = $(this).find(".fields");
      var $summary = $(this).find(".summary");
      $(this).addClass("closed");
      // slideUp não funciona se o parent estiver hidden
      if($fields.parent().is(":hidden")){
        $fields.hide();
      }else{
        $fields.slideUp();
      }
      $(this).refreshExerciseSummary();
      $summary.slideDown();
    });
  };

  // Atualiza informações no summary
  $.fn.refreshExerciseSummary = function(){
    return this.each(function(){
      var $fields = $(this).find(".fields")
      var $summary = $(this).find(".summary");

    // Remove classe das alternativas  habilitadas
    $fields.find(".alternative-item:last").prevAll(".alternative-item").removeClass("disabled")

      var qttAlternatives = $fields.find(".alternative-container .alternative-item.visible:not(.disabled) textarea.alternative-text[value!=\"\"]").length;
    $summary.find(".alternatives .qtt").text(qttAlternatives);
    var statement = $fields.find(".question-statement").val();
    if (statement != ""){
      $summary.find(".statement").text(statement);
    }else{
      $summary.find(".statement").text("(Enunciado não informado)");
    }

    // Pega numeração da alternativa correta
    var correctAlternative = $fields.find("input:checked").prevAll("label").text();
    if (correctAlternative != ""){
      $summary.find(".alternatives .correct").text(correctAlternative.split(":")[0]);
    }else{
      $summary.find(".alternatives .correct").text("(não marcada)");
    }
    });
  };

  // Atualiza numeração das questões
  $.fn.refreshQuestionsNumbering = function(){
    return this.each(function(){
      var $questions = $(this).parent().find(".question-item.visible");
      $questions.each(function(index){
        $(this).find(".position").text(index + 1);
      });
    });
  };

  $.fn.refreshArQuestionsNumbering = function(){
    return this.each(function(){
      var $ar_questions = $(this).parent().find(".ar-question-item.visible");
      $ar_questions.each(function(index){
        $(this).find(".position").text(index + 1);
      });
    });
  };

  // Atualiza letras das alternativas
  $.fn.refreshAlternativesNumbering = function(){
    return this.each(function(){
      var $alternatives = $(this).parent().find(".alternative-item.visible");
      var alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
      $alternatives.each(function(index){
        var letter = alphabet[index];
        $(this).find(".alternative-label").text(letter + ":");
      });
    });
  };

  // Aplica nestedFields a todos os exercícios já criados (edição)
  $.fn.refreshNestedFieldsEdition = function(){
    $("#resources-edition .edit-resource.exercise").each(function(){
      $(this).refreshNestedFields();
    });
  };

  // Habilita alternativas já existentes
  $.fn.refreshAlternativesAppearance = function(){
    $(this).find(".alternative-container").find(".alternative-item:not([data-new-record='true']):last").click();
  };

  // Deixa apenas uma alternativa marcada como certa
  $("#space-manage .concave-form .question-item .concave-multiple").live("change", function(e){
    $(this).parent().siblings().find(".concave-multiple").attr("checked", false)
  });

  // Fecha as questões que não possuem erro de validação
  $.fn.closeQuestionsWithoutErrors = function(){
    return this.each(function(){
      var qttFieldErrors = $(this).find(".field_with_errors").length;
      var qttInlineErrors = $(this).find(".errors_on_field li").length;
      if(qttFieldErrors  === 0 && qttInlineErrors === 0){
        $(this).retractQuestion();
      }
    });
  };

  // Mostra mensagem de carregando enquanto a questão está sendo salva
  var showLoadingMessage = function (show) {
    var loading = $("#loading-message");
    if (show) {
      loading.show();
    }else{
      loading.hide();
    };
  };

  var disableQuestionNavButtons = function (disable) {
    var lectureButtons = $(".actions-buttons .lecture-buttons a, actions-buttons button");
    var $links = $(".exercise-nav a");

    if (disable) {
      lectureButtons.attr("disabled", "disabled");
      $links.addClass("link-disabled");
    } else {
      lectureButtons.removeAttr("disabled");
      $links.removeClass("link-disabled");
    }
  }

  $(document).on("click", "a.link-disabled", function(e) {
    e.preventDefault();
  });

  // Ao clicar no radio button, submete o form de choice
  $.fn.saveQuestion = function(){
    return this.each(function(){
      $(this).on("click", function(e){
        showLoadingMessage(true);
        disableQuestionNavButtons(true);
        $("#form-choice").submit();
      });
    });
  };

  // Radio buttons salvam automaticamente as questões, via AJAX
  $(".exercise input:radio").saveQuestion();

  // Atualiza para apenas a última alternativa ter aparência disabled
  // e deixa apenas as questões com erro abertas
  $.fn.refreshQuestionsAppearance = function(){
    return this.each(function(){
      $(this).refreshAlternativesAppearance();
      $(this).find(".question-item").closeQuestionsWithoutErrors();
    });
  };

  $.fn.refreshFormQuestions = function(){
    $("#aberta").click(function(){
      $("#dissertative").style.display = "block";
      $("#multiple_choice").style.display = "none";
    });
    $("#fechada").click(function(){
      $("#dissertative").style.display = "none";
      $("#multiple_choice").style.display = "block";
    });
  };

  $(document).ready(function(){
    $(document).refreshNestedFieldsEdition();
    $("#resources-edition .exercise").refreshQuestionsAppearance();
    $(document).refreshFormQuestions();

    $(document).ajaxComplete(function(){
      $(document).refreshNestedFieldsEdition();
      $("#resources-edition .exercise").refreshQuestionsAppearance();
      $(".exercise-nav .actual").addClass("question-answered");
      showLoadingMessage(false);
      disableQuestionNavButtons(false);
      $(document).refreshFormQuestions();
    });
  });

  $(document).on("click", ".concave-clean[disabled]", function(e) {
    e.preventDefault();
  });
});
