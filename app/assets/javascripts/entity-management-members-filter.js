// Submete o formulário no marcar dos checkboxes dos filtros.
$(document).on("change", ".entity-mangement-members-filter-form input:checkbox", function() {
  $(this).closest(".entity-mangement-members-filter-form").submit();
});

// Seleciona/desmarca todos os checkboxes dos membros.
$(document).on("change", ".environment-management-member-search-result .form-checklist .form-checklist-all", function() {
  var $checkboxAll = $(this);
  var $checkboxes = $checkboxAll.closest(".form-checklist").find("tbody input:checkbox");

  if ($(this).prop("checked")) {
    $checkboxAll.attr("title", "Desmarcar todos abaixo");
    $checkboxes = $checkboxes.filter("input:checkbox:not(:checked)").prop("checked", true);
  } else {
    $checkboxAll.attr("title", "Selecionar todos abaixo");
    $checkboxes = $checkboxes.filter("input:checkbox:checked").prop("checked", false);
  }

  $checkboxes.reduTables("toggleState");
  $checkboxAll.tooltip("fixTitle");
});