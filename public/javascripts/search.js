$(function(){
  $.fn.searchTokenInput = function(url) {
    $this = $(this)

    $(this).tokenInput(
      url + "?format=json", {
        crossDomain: false,
        hintText: "Faça sua busca",
        noResultsText: "Sem resultados",
        searchingText: "Buscando...",
        onAdd: function (item) {
        // TODO FUnção quando o usuário selecionar opção do tokenInput
        }
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
