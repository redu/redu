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

    var loadGraph = function(json) {
      options.series[0].data[0] = ['Quantidade de respostas aos pedidos de ajuda', json.answered_helps];
      options.series[0].data[1] = {
        name: 'Quantidade de pedidos de ajuda',
        sliced: true,
        selected: true,
        y: json.helps
      };

      chart = new Highcharts.Chart(options);
    };
});
