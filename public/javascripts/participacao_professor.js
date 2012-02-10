$(document).ready(function(){
  var chart;
  var $content = $("#chart");

  var options = {

    chart: {
      renderTo: $content[0],
      defaultSeriesType: 'area'
    },

    title: {
      text: 'Participação do Professor na Disciplina'
    },

    xAxis:{
      categories: ['d1','s2','t3','q4','q5','s6','s7', 'd8', 's9', 't10'],
      title: {
        text: 'Dias'
      }
    },

    yAxis: {
      title:{
        text: 'Colaborações'
      }
    },

    series: [{
      name: 'Quantidade de Aulas Criadas',
      data: [4, 1, 2, 0, 1, 4, 5, 2, 1, 0]
    }, {
      name: 'Quantidade de Postagens',
      data: [20, 10, 3, 4, 12, 9, 5, 19, 21, 5]
    }, {
      name: 'Quantidade de Respostas',
      data: [2, 5, 6, 10, 2, 13, 20, 9, 10, 1]
    }, {
      name: 'Tempo de Espera',
      data: [1, 4, 7, 9, 10, 3, 5, 20, 9, 1]
    }]
  };

  chart = new Highcharts.Chart(options);

  d3.json("/api/dashboard/teacher_participation.json?id_teacher=1&id_course=1", function(json){
  }t;
});
