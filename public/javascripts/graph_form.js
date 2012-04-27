var graphForm = function () {
  // Tratamento das datas
  var time_selected = function (period) {
    var that = this;

    select = $("#date_"+period+"_fake__3i");
    that.day = select[0].options[select[0].selectedIndex].value;
    select = $("#date_"+period+"_fake__2i");
    that.month = select[0].options[select[0].selectedIndex].value;
    select = $("#date_"+period+"_fake__1i");
    that.year = select[0].options[select[0].selectedIndex].value;
    return that.year + "-" + that.month + "-" + that.day;
  };

  var validate_date = function () {
    var st = Date.parse(time_selected("start"));
    var en = Date.parse(time_selected("end"));

    return st < en;
  }

  // Tratamento dos checkboxes
  $(".item-chart-check").click(function () {
    var all = $("#all-check")[0];
    if (!this.checked){
      all.checked = false;
    }
    else{
      var ipts = $(".item-chart-check");
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

  $("#all-check").click(function () {
    var ipts = $(".item-chart-check");
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
    return ($(".error_explanation")).length
  };

  // Submissão do gráfico por AJAX
  $("#graph-form").submit(function(e) {
    $("#date_start").val(time_selected("start"));
    $("#date_end").val(time_selected("end"));

    if(!validate_date()){
      if(!errorExist()){
        $('#form-problem').before('<div class="error_explanation" id="error_explanation"><h2>Ops!</h2><p>Há problemas para os seguinte(s) campo(s):</p><p class="invalid_fields">Data inicial, Data final</p></div>');
        $("#date-validate").append('<ul class="errors_on_date"><li>'+"Intervalo de tempo inválido"+'</li></ul>');
      }
      return false;
    }
  });

  // Requisição AJAX para carregamento do gráfico + Tratamento de erros
  $("#graph-form").live("ajax:complete", function(e, xhr){
    json = $.parseJSON(xhr.responseText);
    if(errorExist){
      $(".error_explanation").remove();
      $(".errors_on_date").remove();
    }

    build_graph();
  });

  var build_graph;

  return {
    load_graph :function (create_graph) {
      build_graph = create_graph;
      $("#graph-form").submit();
    }
  }
};
