$(document).ready(function(){
  var chart;

  // Definição do gráfico
  var options = {
    chart: {
      renderTo: 'teacher-participation-chart',
      defaultSeriesType: 'line'
    },
    title: {
      text: ''
    },
    xAxis:{
      title: {
        text: 'Dias'
      }
    },
    yAxis: {
      title:{
        text: 'Colaborações'
      },
      min: 0
    },
    tooltip: {
      crosshairs: true,
      shared: true,
      formatter: function () {
        var s = '<tspan style="font-weight:bold; text-align:center">'+this.x+'</tspan><br/>';
        $.each(this.points, function (i) {
          s += '<tspan style="fill:'+this.series.color+'">'
            +this.series.name+'</tspan>'
          s += '<span dx="3">: </span>'
          s += '<span style="font-weight:bold; text-align:right" dx="3">'
            +this.y+'</span><br/>'
        })
        return s;
      }
    },
    series: [{
      name: 'Quantidade de Aulas Criadas',
    }, {
      name: 'Quantidade de Postagens',
    }, {
      name: 'Quantidade de Respostas',
    }]
  };

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

  // Tratamento dos checkboxes
  $(".item-space-check").click(function () {
    var all = $("#all-check")[0];
    if (!this.checked){
      all.checked = false;
    }
    else{
      var ipts = $(".item-space-check");
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
    var ipts = $(".item-space-check");
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

  var errorExist = function (){
    return ($(".error_explanation")).length
  };

  // Submissão do gráfico por AJAX
  $("#graph-form").submit(function(e) {
    $("#date_start").val(time_selected("start"));
    $("#date_end").val(time_selected("end"));
  });

  $("#graph-form").live("ajax:complete", function(e, xhr){
    json = $.parseJSON(xhr.responseText);
    if(json.error){
      if(!errorExist()){
        $('#form-problem').before('<div class="error_explanation" id="error_explanation"><h2>Ops!</h2><p>Há problemas para os seguinte(s) campo(s):</p><p class="invalid_fields">Data inicial, Data final</p></div>');
        $("#date-validate").append('<ul class="errors_on_date"><li>'+json.error+'</li></ul>');
      }
    }else{
      if(errorExist){
        $(".error_explanation").remove();
        $(".errors_on_date").remove();
      }
      options.series[0].data = json.lectures_created;
      options.series[1].data = json.posts;
      options.series[2].data = json.answers;

      options.xAxis.categories = json.days;
      chart = new Highcharts.Chart(options);
    }
  });
});
