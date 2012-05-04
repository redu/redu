// Função que trata dos elementos do form relacionado aos gráficos HighCharts,
// Manipulação dos selects das datas, checkboxs e função de submit do form
// Além de tratar eventos de erro com mensagens e
// método submit construindo novo gráfico

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

  var validateDate = function () {
    var st = Date.parse(timeSelected("start").replace(/\-/ig, '/'));
    var en = Date.parse(timeSelected("end").replace(/\-/ig, '/'));

    return st < en;
  }

  // Tratamento dos checkboxes
  $this.find(".item-chart-check").click(function () {
    var all = $this.find("#all-check")[0];
    if (!this.checked){
      all.checked = false;
    }
    else{
      var ipts = $this.find(".item-chart-check");
      var all_checked = true;
      $.each(ipts, function () {
        if(!this.checked){
          all_checked = false
        }
      })

      if (all_checked) {
        all.checked = true;
      }
    }
  });

  $this.find("#all-check").click(function () {
    var ipts = $this.find(".item-chart-check");
    if (this.checked) {
      $.each(ipts, function () {
        this.checked = true;
      })
    }
    else{
      $.each(ipts, function () {
        this.checked = false;
      })
    }
  });

  // Função checa se mensagem de erro está ativa
  var errorExist = function (){
    return ($this.find(".error_explanation")).length
  };

  // Submissão do gráfico por AJAX
  $this.submit(function(e) {
    $this.find("#date_start").val(timeSelected("start"));
    $this.find("#date_end").val(timeSelected("end"));

    if(!validateDate()){
      if(!errorExist()){
        $this.find('#form-problem').before('<div class="error_explanation" id="error_explanation"><h2>Ops!</h2><p>Há problemas para os seguinte(s) campo(s):</p><p class="invalid_fields">Data inicial, Data final</p></div>');
        $this.find("#date-validate").append('<ul class="errors_on_date"><li>'+"Intervalo de tempo inválido"+'</li></ul>');
      }
      return false;
    }
  });

  // Requisição AJAX para carregamento do gráfico + Tratamento de erros
  $this.live("ajax:complete", function(e, xhr){
    json = $.parseJSON(xhr.responseText);
    if(errorExist){
      $this.find(".error_explanation").remove();
      $this.find(".errors_on_date").remove();
    }

    buildGraph();
  });

  var buildGraph;

  return {
    loadGraph :function (createGraph) {
      buildGraph = createGraph;
      $this.before($("<div/>", { id: divRender }));
      $this.submit();
    }
  }
};
