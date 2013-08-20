// Objeto para carregamento do Pie Charts
var SubjectPie = function () {
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
                return '<strong>' + this.point.name + '</strong>: ' + Highcharts.numberFormat( this.percentage, 1 )+ ' %';
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
                ['Pedidos de ajuda sem resposta'],
                {
                  name: 'Pedidos de ajuda que tiveram resposta',
                  sliced: true,
                  selected: true
                },
            ]
        }]
    }

    // Carregamento do Pie Chart
    var loadPie = function (subject, div) {
      options.chart.renderTo = div;
      options.series[0].data[0] = {
        name: 'Pedidos de ajuda que tiveram resposta',
        sliced: true,
        selected: true,
        y: subject.data.helps_answered
      };
      options.series[0].data[1] = ['Pedidos de ajuda sem resposta',
        subject.data.helps_not_answered];

      new Highcharts.Chart(options);
    };

    // Retorno do objeto
    return {
      load: function (subject, div) {
        loadPie(subject, div);
      }
    }
};

// Objeto para carregamento do Bullet Charts
var SubjectBullet = function () {
    // Parametros de tamanho do bullet
    var h = 65;

    var d3chart = d3.chart.bullet()
        .height(15);

    // Carregamento do bullet
    var loadBullet = function(data, div) {
      var vis = d3.select(div).selectAll("svg")
        .data(data)
        .enter().append("svg")
        .attr("height", h)
        .append("g")
        .attr("transform", "translate(5, 0)")
        .call(d3chart);

      var title = vis.append("g")
        .attr("text-anchor", "start");

      // Subtítulo do bullet charts
      title.append("text")
        .attr("class", "legend")
        .attr("dy", "4.5em")
        .text("Total de alunos X Total de alunos que finalizaram o módulo");

      // Atributo title para o tooltip
      d3.selectAll("rect")
        .attr("rel", "tooltip")
        .attr("title", "Total de alunos: " + data[0].ranges[0] +
            "<br/>Total de alunos que finalizaram o módulo: " + data[0].measures[0]);
    };

  // Retorno do objeto
  return {
    load: function (data, div) {
      loadBullet(data, div);
    }
  };
};

var SubjectParticipation = function () {
  var loadGraphs = function (url, token, subjects) {
    var pie = new SubjectPie();
    var bullet = new SubjectBullet();

    var divPie = "subject-participation-pie-";
    var divBullet = "#subject-participation-bullet-";

    $.ajax({
      url: url + "?oauth_token=" + token + subjects,
      method: "GET",
      dataType: 'jsonp',
      success: function (json) {
        $.each(json, function (index, object) {
          pie.load(object, divPie + object.subject_id);
          bullet.load(buildJSON (object), divBullet + object.subject_id);
        });
      }
    });
  }

  var buildJSON = function (object) {
    return [{ "ranges": [object.data.enrollments],
      "measures": [object.data.subjects_finalized],
      "markers": [object.data.enrollments] }]
  }

  return {
    load: function (url, token, subjects) {
      loadGraphs(url, token, subjects);
    }
  }
}
