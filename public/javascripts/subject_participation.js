// Objeto para carregamento do Pie Charts
var subject_participation_pie = function () {
    var chart;

    // Configuração padrão do pie chart
    var options = {
        chart: {
            defaultSeriesType: 'pie'
        },
        credits: {
            enabled: false
        },
        title: {
            text: ''
        },
        tooltip: {
            formatter: function() {
                return '<b>' + this.point.name + '</b>: ' + Highcharts.numberFormat( this.percentage, 1 )+ ' %';
            },
            valueDecimals: 1
        },
        plotOptions: {
            pie: {
                allowPointSelect: true,
                cursor: 'pointer',
                dataLabels: {
                    enabled: false
                },
            }
        },
        series: [{
            type: 'pie',
            data: [
                ['Quantidade de respostas aos pedidos de ajuda'],
                {
                  name: 'Quantidade de pedidos de ajuda',
                  sliced: true,
                  selected: true
                },
            ]
        }]
    }

    // Carregamento do Pie Chart
    var loadPie = function(subject_id, ur) {
      var url = ur + "?subject_id=" + subject_id;

      $.getJSON(url, function (json) {
        options.chart.renderTo = 'subject-participation-pie-'+subject_id;
        options.series[0].data[0] = {
          name: 'Pedidos de ajuda que tiveram resposta',
          sliced: true,
          selected: true,
          y: json.helps_answered
        };
        options.series[0].data[1] = ['Pedidos de ajuda sem resposta', json.helps_not_answered];

        new Highcharts.Chart(options);
      })
    };

    // Retorno do objeto
    return {
      load_subject_participation_pie: function (subject_id, url) {
        loadPie(subject_id, url);
      }
    }
};

// Objeto para carregamento do Bullet Charts
var subject_participation_bullet = function () {
    // Parametros de tamanho do bullet
    var w = 390,
        h = 107.5,
        m = [52.5, 30, 40, 20]; // top right bottom left

    var d3chart = d3.chart.bullet()
        .width(w - m[1] -m[3])
        .height(h -m[0] -m[2]);

    // URL activities_d3
    // Carregamento do bullet
    var loadBullet = function(subject_id, ur){
      var url = ur + "?subject_id=" + subject_id;

      d3.json(url, function(data) {
      var vis = d3.select("#subject-participation-bullet-"+subject_id).selectAll("svg")
        .data(data)
        .enter().append("svg")
        .attr("class", "bullet")
        .attr("width", w)
        .attr("height", h)
        .append("g")
        .attr("transform", "translate(" + m[3] + "," + m[0] + ")")
        .call(d3chart);

      var title = vis.append("g")
        .attr("text-anchor", "start");

      // Subtítulo do bullet charts
      title.append("text")
        .attr("class", "subtitle-chart")
        .attr("dy", "4.5em")
        .text("Total de alunos X Total de alunos que finalizaram o módulo");

      // Atributo title para o tooltip
      d3.selectAll("rect")
        .attr("title", "Total de alunos: " + data[0].ranges[0] +
            "<br/>Total de alunos que finalizarama o módulo: " + data[0].measures[0]);

      // Configuração default do tooltip
      $('.subject-participation-bullet > svg > g > rect.range').tipTip({defaultPosition: "top"});
      $('.subject-participation-bullet > svg > g > rect.measure').tipTip({defaultPosition: "top"});
    });
  };

  // Retorno do objeto
  return {
    load_subject_participation_bullet: function (subject_id, url) {
      loadBullet(subject_id, url);
    },
  };
};
