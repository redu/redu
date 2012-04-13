var subject_participation_pie = function () {
    var chart;
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
                return '<b>' + this.point.name + '</b>: ' + this.percentage + ' %';
            }
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

    // Pie Chart
    var loadPie = function(subject_id) {
      var url = "http://localhost:3000/subjects/activities.json?subject_id=1";

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

    return {
      load_subject_participation_pie: function (subject_id) {
        loadPie(subject_id);
      }
    }
};

// Carregamento do Bullet Charts
var subject_participation_bullet = function () {
    var w = 418,
        h = 107.5,
        m = [52.5, 30, 40, 20]; // top right bottom left

    var d3chart = d3.chart.bullet()
        .width(w - m[1] -m[3])
        .height(h -m[0] -m[2]);

    // URL activities_d3
    var loadBullet = function(subject_id){
      d3.json("http://localhost:3000/subjects/activities_d3.json?subject_id=1", function(data) {
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

      title.append("text")
        .attr("class", "subtitle-chart")
        .attr("dy", "4.5em")
        .text("Total de alunos X Total de alunos que finalizaram o módulo");
      });
    };

    return {
      load_subject_participation_bullet: function (subject_id) {
        loadBullet(subject_id);
      }
    };
};
