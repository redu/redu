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

  $("#course_name, #course_path").live('keyup blur', function(e){
    var slugedPath = $(this).slug();
    $("#course_path").val(slugedPath);
    $("#environment-manage .course-path .course-name, #course-manage .course-path .course-name").html(slugedPath);
  });

  // Colorindo tabela de roles
  $.fn.refreshRoleTable = function(){
    return $("#environment-manage .admin-role-table tr:even").addClass("even");
  };

  $(document).ready(function(){
    $(document).refreshRoleTable();

    $(document).ajaxComplete(function(){
      $(document).refreshRoleTable();
    });
  });

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

  $(".page-form").live("ajax:before", function(){
    for (instance in CKEDITOR.instances){
      var $ckEditor = $("#" + instance);

      if($ckEditor.length === 0) {
        CKEDITOR.remove(CKEDITOR.instances[instance]);
      } else {
        CKEDITOR.instances[instance].updateElement();
      }
    }
  });

  $("#space-manage .new-resource .concave-form .cancel-lecture").live("click", function(e){
    $(this).parents("#lecture_form").slideUp();
    $("#space-manage .new-resource .resources-types li").removeClass("selected");
    e.preventDefault();
  });

  $("#space-manage .edit-resource .concave-form .cancel-lecture").live("click", function(e){
    $(this).parents(".edit-resource").slideUp();
    e.preventDefault();
  });

  $("#space-manage .resources > li .edit").live("click", function(e){
    var $item = $(this).parent();
    $item.toggleClass("editing");
    $("#" + $item.attr("id") + "-edition").slideToggle();
    e.preventDefault();
  });

  $.fn.refreshResourcesNumbering = function(){
    var qttResources = $("#resources_list > li:not(.no-lectures)").length;
    $(this).find(".position").text(qttResources + 1);

    if(qttResources > 0){
      $("#resources_list > li.no-lectures").remove();
    }else{
      $("#resources_list").html($("<li/>", { "class" : "no-lectures", "text" : "Nenhuma aula foi adicionada ainda."}))
    }
  };

})(jQuery);
