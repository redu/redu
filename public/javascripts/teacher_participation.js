$(document).ready(function(){
  var chart;
  var $content = $("#teacher-participation-chart");
  var id_course;

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

  // Inicialização default do gráfico
  initialize_graph = function () {
    var that = this;

    $.getJSON("../api/dashboard/teacher_participation.json?id_course="+that.id_course,
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

  // Método chamado após apertar Update
  graph_interaction = function () {
    var that = this;

    // Teacher selecionado
    var select = $("#teacher-select-chart #user_id");
    var id_teacher = select[0].options[select[0].selectedIndex].value;

    // Checkboxes de spaces selecionados
    select = $(".space-choosen-chart .item-space-check");
    var spaces = [];
    $.each(select, function () {
      if(this.checked){
        spaces.push(this.value);
      }
    });

    // Time range selecionado
    select = $(".item-time-range-chart #date_start_start_3i");
    var day = select[0].options[select[0].selectedIndex].value;
    select = $(".item-time-range-chart #date_start_start_2i");
    var month = select[0].options[select[0].selectedIndex].value;
    select = $(".item-time-range-chart #date_start_start_1i");
    var year = select[0].options[select[0].selectedIndex].value;

    var start_time = year+"-"+month+"-"+day;

    select = $(".item-time-range-chart #date_end_start_3i");
    day = select[0].options[select[0].selectedIndex].value;
    select = $(".item-time-range-chart #date_end_start_2i");
    month = select[0].options[select[0].selectedIndex].value;
    select = $(".item-time-range-chart #date_end_start_1i");
    year = select[0].options[select[0].selectedIndex].value;

    var end_time = year+"-"+month+"-"+day;

    $.getJSON("../api/dashboard/teacher_participation_interaction.json?id_course="+that.id_course+"&id_teacher="+id_teacher+"&time_start="+start_time+"&time_end="+end_time+"&spaces[]="+spaces,
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

  // Tratamento dos checkboxes
  $(".space-choosen-chart .item-space-check").click(function () {
    if (this.checked === false){
      var all = $(".space-choosen-chart #all-check")[0];
      all.checked = false;
    }
  });

  $(".space-choosen-chart #all-check").click(function () {
    var ipts = $(".space-choosen-chart .item-space-check");
    if (this.checked) {
      $.each(ipts, function () {
        this.checked = true;
      })
    }
    else{
      $.each(ipts, function () {
        this.checked = false;
      });
    };
  });
});
