$(function(){
  $.fn.searchTokenInput = function(url) {
    $(this).tokenInput(
      url + "?format=json", {
        crossDomain: false,
        hintText: "Faça sua busca",
        noResultsText: "Sem resultados",
        searchingText: "Buscando...",
    });
  }

  var updateTokenInput = function(url) {
    $(".token-input-list").remove();
    $("#q").searchTokenInput(url);
  }

  updateTokenInput($(".form-search").attr("action"));

  $(".form-search-filters-dropdown :radio").change(function() {
    $this = $(this)[0];

    if($this.value === "geral"){
      url = "/busca"
    }else if($this.value === "ambientes") {
      url = "/busca/ambientes"
    }else if($this.value === "perfil") {
      url = "/busca/perfis"
    }

    $(".form-search").attr("action", url);
    updateTokenInput(url);
  });
});
