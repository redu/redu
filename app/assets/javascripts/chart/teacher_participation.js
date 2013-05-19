// Módulo respnsável pela criação do gráfico Basic Line do relatório
// de participação dos professores nas disciplinas do curso

var TeacherParticipationGraph = function () {
  var chart;

  // Definição do gráfico
  var options = {
    chart: {
      renderTo: '',
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
      shared: true
    },
    series: [{
      name: 'Quantidade de Aulas Criadas',
    }, {
      name: 'Quantidade de Postagens',
    }, {
      name: 'Quantidade de Respostas',
    }]
  };

  return {
    // Carregamento do gráfico
    load: function (graphView) {
      // Inicializa o form com o gráfico correspondente
      var graph = graphView.form.plotGraphForm(graphView.chart.renderTo);

      // Passa a função de carregamento do gráfico via JSON
      graph.loadGraph(function (json) {
        $.extend(options, graphView);

        options.series[0].data = json.lectures_created;
        options.series[1].data = json.posts;
        options.series[2].data = json.answers;

        options.xAxis.categories = json.days;
        chart = new Highcharts.Chart(options);
      });
    }
  }
};
