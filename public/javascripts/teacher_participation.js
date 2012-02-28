$(document).ready(function(){
  var chart;
  var $content = $("#teacher-participation-chart");

  var options = {
    chart: {
      renderTo: $content[0],
      defaultSeriesType: 'area'
    },

    title: {
      text: 'Participação do Professor na Disciplina'
    },

    xAxis:{
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
    }, {
      name: 'Quantidade de Postagens',
    }, {
      name: 'Quantidade de Respostas',
    }]
  };

  initialize_graph = function (id_course) {
    $.getJSON("../api/dashboard/teacher_participation.json?id_course="+id_course,
    function(json){
      if (json.erro) {
        options.title.text = json.erro
      }
      else{
        options.series[0].data = json.lectures_created;
        options.series[1].data = json.posts;
        options.series[2].data = json.answers;

        options.xAxis.categories = json.days;
      };
        chart = new Highcharts.Chart(options);
    });
  };
});
