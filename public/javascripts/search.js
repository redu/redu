$(function() {
  // Adiciona o tokeninput a um campo com dados da dada URL.
  $.fn.searchTokenInput = function(url) {
    $(this).tokenInputInstaSearch(
      url + "?format=json", {
        crossDomain: false,
        hintText: "Faça sua busca",
        noResultsText: "Sem resultados",
        searchingText: "Buscando...",
        minChars: 3,
        // Evita que o plugin funcione como tokenizador.
        tokenLimit: 0,
        resultsLimit: 6,
        // Adiciona esse sufixo para as classes do plugin.
        theme: "redu",
        searchDelay: 600,
        resultsFormatter: function(item) {
          return ('<li class="portal-search-result-item control-autocomplete-suggestion"><a class="control-autocomplete-suggestion-link" href="' + item.links[0].href + '" title="' + item.name + '"><img class="control-autocomplete-thumbnail" src="' + item.thumbnail + '" width="32" height="32"/><div class="control-autocomplete-added-info"><span class="control-autocomplete-name text-truncate">' + item.name + '</span><span class="control-autocomplete-mail legend text-truncate">' + item.legend + '</span></div></a></li>');
        },
        onAdd: function(item) {
          // Redireciona quando um item é clicado.
          window.location.href = item.links[0].href;
        }
    });
  };

  var updateTokenInput = function(url) {
    // Remove o tokeninput anterior.
    $(".token-input-list-redu").remove();
    // Adiciona um novo.
    $("#q").searchTokenInput(url);
  };

  updateTokenInput($(".form-search").attr("action"));

  // Altera o action do form e tokeninput de acordo com o filtro selecionado.
  $(document).on("change", ".form-search-filters-dropdown input:radio", function() {
    var val = $(this).val()
      , url = "/busca";

    if (val === "ambientes") {
      url = url + "/ambientes";
    } else if (val === "perfil") {
      url = url + "/perfis";
    }

    $(".form-search").attr("action", url);
    updateTokenInput(url);
  });

  // Evita que o formulário seja submetido vazio.
  $(document).on("submit", ".form-search", function(e) {
    var val = $(this).find('#token-input-q').val();
    if ($.trim(val) === "") {
      return false;
    }
  });

  // Organiza o dropdown de resultados.
  $(document).on("organizeResults", ".token-input-dropdown-redu", function() {
    var $dropdown = $(this)
      , $list = $dropdown.find("ul")
      , $results = $list.find(".portal-search-result-item")
      , maxResults = 5
      , filter = $(".form-search-filters input:radio:checked").val();

    if (filter === "geral") {
      var $profiles = $results.filter(function() {
          return $(this).data("tokeninput").type === "profile";
        })
        , $environments = $results.filter(function() {
          return $(this).data("tokeninput").type === "environment";
        })

      if ($profiles.length > 0) {
        $list.prepend('<li class="portal-search-result-category icon-profile-gray_16_18-before">Perfis</li>');
      }

      if ($environments.length > 0) {
        $firstEnvironment = $results.filter(function() {
          return $(this).data("tokeninput").type === "environment";
        }).first();

        $('<li class="portal-search-result-category icon-environment-gray_16_18-before">Ambientes de Aprendizagem</li>').insertBefore($firstEnvironment);
      }
    } else {
      if ($results.length > maxResults) {
        var linkSeeMore = $(".form-search").attr("action") + "?q=" + $("#token-input-q").val();

        $results.last().remove();
        $dropdown.append('<hr><a class="portal-search-link-see-more" title="Ver mais resultados" href="' + linkSeeMore + '">Ver mais</a>');
      }
    }
  });
});