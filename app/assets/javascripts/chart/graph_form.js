// Função que trata dos elementos do form relacionado aos gráficos HighCharts,
// Manipulação dos selects das datas e função de submit do form
// Além de tratar eventos de erro com mensagens

$.fn.plotGraphForm = function (divRender) {
  var $this = $(this);

  // Tratamento das datas
  var timeSelected = function (period) {
    select = $("#date_"+period+"_fake__3i");
    var day = select[0].options[select[0].selectedIndex].value;
    select = $("#date_"+period+"_fake__2i");
    var month = select[0].options[select[0].selectedIndex].value;
    select = $("#date_"+period+"_fake__1i");
    var year = select[0].options[select[0].selectedIndex].value;
    return year + "-" + month + "-" + day;
  };

  // Validando intervalo de datas
  // O replace é para browsers que não tem o mesmo formato de String do SO,
  // e portanto retornam NaN no parse
  var validateDate = function () {
    var st = Date.parse(timeSelected("start").replace(/\-/ig, '/'));
    var en = Date.parse(timeSelected("end").replace(/\-/ig, '/'));

    return st < en;
  }

  // Função checa se mensagem de erro está ativa
  var errorExist = function (){
    return $this.find(".report-form-errors").length;
  };

  // Submissão do gráfico por AJAX
  $this.submit(function(e) {
    $this.find(".reports-form-date-start").val(timeSelected("start"));
    $this.find(".reports-form-date-end").val(timeSelected("end"));

    // Só submita se a data for válida
    if(!validateDate()){
      if(!errorExist()){
        $this.prepend('<div class="content-section report-form-errors"><div class="message-block message-warning fade in"><div class="message-block-content"><span class="show"><strong>Ops!</strong> Há problemas para os seguinte(s) campo(s):</span>Data inicial, Data final</div></div></div>');
        $this.find(".report-form-error-date").append('<p class="control-errors">Intervalo de tempo inválido</p>');
      }

      // Não submita e também não chama o método live
      return false;
    }
  });

  // Requisição AJAX para carregamento do gráfico + Tratamento de erros
  $this.live("ajax:complete", function(e, xhr){
    var json = $.parseJSON(xhr.responseText);
      if(errorExist){
        $this.find(".report-form-errors").remove();
        $this.find(".report-form-error-date .control-errors").remove();
      }

      // As requisições cross-domain não devolvem este callback,
      // sendo necessário outro callback do tipo sucess, o try catch
      // não deixa a exceção ser levantada para o usuário
      try{
        buildGraph(json);
      }
      catch(e){}
  });

  // Função de carregamento do gráfico
  var buildGraph;

  return {
    loadGraph :function (createGraph) {
      buildGraph = createGraph;

      // Primeiro carregamento do gráfico
      $this.before($("<div/>", { id: divRender }));
      $this.submit();
    }
  }
};
