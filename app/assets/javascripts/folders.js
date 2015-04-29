// Mostra/esconde os elementos de renomear pasta.
$(document).on("click", ".folder-item .toggle-edit", function() {
  var $item = $(this).closest(".folder-item");
  $item.find(".folder-name, .rename-folder").toggle();
});

// Abre/fecha os dropdowns.
$(document).on("click", ".folder-admin .toggle-dropdown", function() {
  var dropdownClass = ".dropdown-menu";
  var $wrapper = $(this).parent();
  var $otherWrapper = $wrapper.siblings();
  var $dropdown = $wrapper.find(dropdownClass);
  var $otherDropdown = $wrapper.siblings().find(dropdownClass);

  $dropdown.slideToggle(150, "swing");
  $otherDropdown.slideUp(150, "swing");
  $wrapper.toggleClass("open");
  $otherWrapper.removeClass("open");
});

// Foca no campo ao clicar no botão de criar nova pasta.
$(document).on("click", ".folder-admin .button-create-folder", function() {
  var $wrapper = $(this).closest(".new-folder");
  var $dropdown = $wrapper.find(".dropdown-menu");

  if ($dropdown.data("open")) {
    $dropdown.data("open", false);
  } else {
    setTimeout(function() {
      $wrapper.find(".new-folder-input").focus();
    }, 100);
    $dropdown.data("open", true);
  }
});