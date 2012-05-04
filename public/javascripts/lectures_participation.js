// Módulo respnsável pela criação do gráfico Stacked Area do relatório
// de participação dos alunos nas aulas da disciplina

var LectureParticipationGraph = function () {
  var chart;

  // Definição do gráfico
  var options ={
    chart: {
      renderTo: '',
      type: 'area'
    },
    title: {
      text: ''
    },
    xAxis: {
      title: {
        text: 'Dias'
      }
    },
    yAxis: {
      title: {
        text: 'Participação'
      },
      min: 0
    },
    legend: {
      layout: 'vertical',
      x: -40
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
    plotOptions: {
      area: {
        stacking: 'normal',
        lineColor: '#666666',
        lineWidth: 1,
        marker: {
          lineWidth: 1,
          lineColor: '#666666'
        }
      }
    },
    series: [{
      name: 'Quantidade de Pedidos de Ajuda',
    }, {
      name: 'Quantidade de Postagens',
    }, {
      name: 'Quantidade de Respostas aos Pedidos de Ajuda',
    }, {
      name: 'Quantidade de Respostas às Postagens'
    }]
  }

  return {
    // Carregamento do gráfico
    load: function (graphView) {
      // Inicializa o form com o gráfico correspondente
      var graph = graphView.form.plotGraphForm(graphView.chart.renderTo);

      // Passa a função de carregamento do gráfico via JSON
      graph.loadGraph(function () {
        $.extend(options, graphView);

        options.series[0].data = json.helps_by_day;
        options.series[1].data = json.activities_by_day;
        options.series[2].data = json.answered_helps_by_day;
        options.series[3].data = json.answered_activities_by_day;

        options.xAxis.categories = json.days;
        chart = new Highcharts.Chart(options);
      })
    }
  }
};
