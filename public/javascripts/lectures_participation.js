var LectureParticipationGraph = function () {
  var chart;

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
    load: function (graphView) {
      var graph = graphView.form.plotGraphForm(graphView.chart.renderTo);

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
