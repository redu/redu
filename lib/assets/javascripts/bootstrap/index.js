//= require rails
//= require modernizr
//= require jquery.autosize.min
//= require placeholder-polyfill
//= require bootstrap/bootstrap-redu

// Re-ativa o tooltip no caso de elementos adicionados dinamicamente.
$(document).ajaxComplete(function() {
  $(".tooltip").remove();
  $('[rel="tooltip"]').tooltip();
});

// Marca/desmarca o checkbox de selecionar todos quando um checkbox comum é clicado.
$(document).on("click", ".controls-check-all input:checkbox", function() {
  var checkbox = this;
  var $wrapper = $(checkbox).closest(".controls-check-all");
  var checkboxAll = $wrapper.find(".control-checkbox-all")[0];

  if (!checkbox.checked) {
    checkboxAll.checked = false;
  } else {
    var $checkboxes = $wrapper.find("input:checkbox:not(.control-checkbox-all)");
    var allChecked = true;

    $.each($checkboxes, function() {
      if (!this.checked) {
        allChecked = false;
        return false;
      }
    });

    if (allChecked) {
      checkboxAll.checked = true;
    }
  }
});

// Checkbox de selecionar todos.
$(document).on("click", ".controls-check-all .control-checkbox-all", function() {
  var $checkboxAll = $(this);
  var $wrapper = $checkboxAll.closest(".controls-check-all");
  var $checkboxes = $wrapper.find("input:checkbox");

  if ($checkboxAll[0].checked) {
    $.each($checkboxes, function() { this.checked = true; });
  } else {
    $.each($checkboxes, function() { this.checked = false; });
  }
});