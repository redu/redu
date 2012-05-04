var TeacherParticipationGraph = function () {
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

  return {
    load: function (graphView) {
      var graph = graphView.form.plotGraphForm(graphView.chart.renderTo);

      graph.loadGraph(function () {
        $.extend(options, graphView);

        options.series[0].data = json.lectures_created;
        options.series[1].data = json.posts;
        options.series[2].data = json.answers;

        options.xAxis.categories = json.days;
        var chart = new Highcharts.Chart(options);
      });
    }
  }
};
