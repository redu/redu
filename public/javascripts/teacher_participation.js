$(document).ready(function(){
  var chart;
  var $content = $("#teacher-participation-chart");
  var id_course;

  // Definição do gráfico
  var options = {
    chart: {
      renderTo: $content[0],
      defaultSeriesType: 'line'
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
      },
      min: 0
    },

    tooltip: {
      crosshairs: true,
      shared: true,
      formatter: function () {
        var s = "";
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

  // Inicialização default do gráfico
  initialize_graph = function () {
    var that = this;

    $.getJSON("/api/dashboard/teacher_participation.json?id_course="
        +that.id_course,
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
    var select = $("#user_id");
    var id_teacher = select[0].options[select[0].selectedIndex].value;

    // Checkboxes de spaces selecionados
    select = $(".item-space-check");
    var spaces = [];
    $.each(select, function () {
      if(this.checked){
        spaces.push(this.value);
      }
    });

    // Time range selecionado
    time_selected("start");
    var start_time = year+"-"+month+"-"+day;

    time_selected("end");
    var end_time = year+"-"+month+"-"+day;

    $.getJSON("/api/dashboard/teacher_participation_interaction.json?id_course="
        +that.id_course+"&id_teacher="+id_teacher+"&time_start="+start_time
        +"&time_end="+end_time+"&spaces[]="+spaces,
        function(json){
          if (json.erro) {
            options.title.text = json.erro
          }
          else{
            options.series[0].data = json.lectures_created;
            options.series[1].data = json.posts;
            options.series[2].data = json.answers;

            options.xAxis.categories = json.days;
          }
          chart = new Highcharts.Chart(options);
        });
  };

  // Tratamento das datas
  var time_selected = function (period) {
    var that = this;

    select = $("#date_"+period+"_start_3i");
    that.day = select[0].options[select[0].selectedIndex].value;
    select = $("#date_"+period+"_start_2i");
    that.month = select[0].options[select[0].selectedIndex].value;
    select = $("#date_"+period+"_start_1i");
    that.year = select[0].options[select[0].selectedIndex].value;
  };

  // Tratamento dos checkboxes
  $(".item-space-check").click(function () {
    var all = $("#all-check")[0];
    if (!this.checked){
      all.checked = false;
    }
    else{
      var ipts = $(".item-space-check");
      var all_checked = true;
      $.each(ipts, function () {
        if(!this.checked){
          all_checked = false
        }
      })

      if (all_checked) {
        all.checked = true;
      }
    }
  });

  $("#all-check").click(function () {
    var ipts = $(".item-space-check");
    if (this.checked) {
      $.each(ipts, function () {
        this.checked = true;
      })
    }
    else{
      $.each(ipts, function () {
        this.checked = false;
      })
    }
  });

 $("#graph-form").submit(function(e) {
    e.preventDefault();
 });

});
