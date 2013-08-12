(function($){
  // Padrão de spinner
  $(".admin-filter-form").live('ajax:before', function(e){
    var $this = $(this);
    var $target = $(e.target);

    if($this.is($target)){
      var $submit = $(this).find("input[type=submit]");
      $submit.loadingStart();
    }
  });

  $(".admin-filter-form").live('ajax:complete', function(){
    $(this).find("input[type=submit]").loadingComplete();
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
        $(itemId + ".resource-numbering .position").text(newPosition);
      });
    }else{
      $(this).html($("<li/>", { "class" : "no-lectures", "text" : "Nenhuma aula foi adicionada ainda."}))
    }
  };

  // Pede confirmação do usuário para finalizar o módulo
  $("#subject_submit").live("click", function(e){
    var $openForms = $(".resource-form:visible");
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

  $(document).ready(function(){
    $(document).refreshRoleTable();
    $(document).refreshFormUpload();
    $(document).ajaxComplete(function(){
      $(document).refreshRoleTable();
      $(document).refreshFormUpload();
    });
  });
})(jQuery);
