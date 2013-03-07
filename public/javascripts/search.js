$(function() {
  $.fn.searchTokenInput = function(url) {
    $this = $(this)

    $(this).tokenInput(
      // TODO: tem algum erro com o controlador. Corrigir com Jess. Por enquanto usa um JSON local para testes.
      // url + "?format=json", {
      [{"links":[{"rel":"self_public","href":"http://127.0.0.1:3000/pessoas/34269290404"}],"id":1902,"name":"Filipe Fernandes"},{"links":[{"rel":"self_public","href":"http://127.0.0.1:3000/pessoas/bmbsmb"}],"id":3997,"name":"Filipe Magalh\u00e3es"},{"links":[{"rel":"self_public","href":"http://127.0.0.1:3000/pessoas/filipefms3"}],"id":333,"name":"Filipe Marques"},{"links":[{"rel":"self_public","href":"http://127.0.0.1:3000/pessoas/filipe"}],"id":414,"name":"Filipe Santos"},{"links":[{"rel":"self_public","href":"http://127.0.0.1:3000/qualidade"}],"id":390,"name":"Qualidade, Relacionamento e Inova\u00e7\u00e3o"},{"links":[{"rel":"self_public","href":"http://127.0.0.1:3000/www"}],"id":45,"name":"Pernambuco"},{"links":[{"rel":"self_public","href":"http://127.0.0.1:3000/computacao-cientifica"}],"id":633,"name":"Computa\u00e7\u00e3o Cient\u00edfica"},{"links":[{"rel":"self_public","href":"http://127.0.0.1:3000/coordenadorticdesouselogmailcom"}],"id":709,"name":"Web2.0"},{"links":[{"rel":"self_public","href":"http://127.0.0.1:3000/lorem-ipsum-dolor-sit-amet-orci-aliquams/cursos/lorem-ipsum-dolor-sit-amet-consectetur-adipiscing-volutpat"}],"id":882,"name":"Lorem ipsum dolor sit amet, consectetur adipiscing volutpat."},{"links":[{"rel":"self_public","href":"http://127.0.0.1:3000/computacao-cientifica/cursos/teoria-da-computacao"}],"id":729,"name":"Teoria da Computa\u00e7\u00e3o"},{"links":[{"rel":"self_public","href":"http://127.0.0.1:3000/coordenadorticdesouselogmailcom/cursos/coordenadorticdesouselogmailcom"}],"id":828,"name":"Web 2.0"},{"links":[{"rel":"self_public","href":"http://127.0.0.1:3000/testepp/cursos/teste"}],"id":860,"name":"teste"},{"links":[{"rel":"slef_public","href":"http://127.0.0.1:3000/espacos/569"}],"id":569,"name":"Refer\u00eancias"},{"links":[{"rel":"slef_public","href":"http://127.0.0.1:3000/espacos/952"}],"id":952,"name":"Matem\u00e1tica Intervalar"},{"links":[{"rel":"slef_public","href":"http://127.0.0.1:3000/espacos/1126"}],"id":1126,"name":"Web2.0"},{"links":[{"rel":"slef_public","href":"http://127.0.0.1:3000/espacos/1175"}],"id":1175,"name":"tested"}], {
        crossDomain: false,
        hintText: "Faça sua busca",
        noResultsText: "Sem resultados",
        searchingText: "Buscando...",
        minChars: 3,
        // Evita que o plugin funcione como tokenizador.
        tokenLimit: 0,
        resultsLimit: 6,
        // Adiciona esse sufixo para as classes do plugin.
        theme: "redu"
    });
  }

  var updateTokenInput = function(url) {
    $(".token-input-list").remove();
    $("#q").searchTokenInput(url);
  }

  // TODO: Re-ativar quando estiver trabalhando na busca instantânea.
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
    // TODO: Re-ativar quando estiver trabalhando na busca instantânea.
    updateTokenInput(url);
  });

  $(".form-search").live("submit", function(){
    var val = $(this).children('input').val();
    if ($.trim(val) === "") {
      return false;
    }
  })

  // BUGFIX: remove o .token-input-list-redu adicionado quando um filtro é escolhido.
  $(document).on("change", "input:radio", function() {
    $(".token-input-list-redu").last().remove();
  })
});
