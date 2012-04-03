$(document).ready(function() {
    var chart;
    var options = {
        chart: {
            renderTo: 'subject-participation-chart',
            defaultSeriesType: 'pie'
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
    var loadGraph = function(json, incremento) {
      options.chart.renderTo = 'subject-participation-chart'+incremento;
      options.series[0].data[0] = ['Quantidade de respostas aos pedidos de ajuda', json.answered_helps];
      options.series[0].data[1] = {
        name: 'Quantidade de pedidos de ajuda',
        sliced: true,
        selected: true,
        y: json.helps
      };

      chart = new Highcharts.Chart(options);
    };

    // Carregamento do Bullet Charts
    var w = 960,
        h = 50,
        m = [5, 40, 20, 120];

    var d3chart = d3.chart.bullet()
        .width(w - m[1] -m[3])
        .height(h -m[0] -m[2]);

    // URL activities_d3
    d3.json("#", function(data) {
      var vis = d3.select("#subject-participation-chart").selectAll("svg")
        .data(data)
        .enter().append("svg")
        .attr("class", "bullet")
        .attr("width", w)
        .attr("height", h)
        .append("g")
        .attr("transform", "translate(" + m[3] + "," + m[0] + ")")
        .call(d3chart);

      var title = vis.append("g")
        .attr("text-anchor", "end")
        .attr("transform", "translate(-6," + (h - m[0] - m[2]) / 2 + ")");

      title.append("text")
        .attr("class", "title")
        .text();

      title.append("text")
        .attr("class", "subtitle")
        .attr("dy", "1em")
        .text();

      chart.duration(1000);
    });
});
