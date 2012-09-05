var StudentsTreemap = function () {
  // Configurações do layout do treemap
  var w = 748,
      h = 400,
      x = d3.scale.linear().range([0, w]),
      y = d3.scale.linear().range([0, h]),
      root,
      color = { red: d3.rgb(193,39,45),
                orange: d3.rgb(243,94,0),
                yellow: d3.rgb(255,200,0),
                green: d3.rgb(95,192,128),
                blue: d3.rgb(77,173,214),
                gray: d3.rgb(230, 230, 230) }
                // Vermelho, Laranja, Amarelo, Verde, Azul, Cinza

  // Função para preenchimento das cores da células, se grade = null preenchimento neutro
  var fill = function (grade){
    if (grade === -1.0) {
      return color.gray;
    }
    else if (grade < 5.0) {
      if (grade < 3.0) {
        return color.red;
      }
      else{
        return color.orange;
      };
    }
    else{
      if(grade < 7.0){
        return color.yellow;
      }
      else if (grade < 9.0) {
        return color.green;
      }
      else{
        return color.blue;
      };
    };
  }

  // Função que retorna o tamanho da célula proveniente do JSON
  var size = function (d) {
    return d.size;
  }

  // Função para construção padrão do JSON do treemap
  var buildJSON = function (vis, api) {
    // JSON conterá apenas um nó pai com seus filhos
    var json = {"name": "treemap",
                "children": []};

    // Para cada aluno do Space eu monto um filho padrão do treemap
    $.each(vis, function (index, object) {
      var item = {};

      // Busca o nome do aluno nos dados da API
      var user = searchUser(vis[index].user_id, api)[0];
      if (user) {
        item.name = user.first_name;
        item.last_name = user.last_name;
        item.id = vis[index].user_id;
      };

      // Participação + nota do aluno
      item.activities = object.data.activities;
      item.helps = object.data.helps;
      item.answered_activities = object.data.answered_activities;
      item.answered_helps = object.data.answered_helps;
      item.size = participation(object.data);
      item.grade = object.data.average_grade;

      // Adiciona novo filho ao JSON
      json.children.push(item);
    })

    return json;
  }

  // Função de participação do aluno, baseado em suas atividades na Disciplina
  var participation = function (data) {
    var part = data.helps + data.activities +
      data.answered_activities + data.answered_helps;

    // O size não pode ser zero pois desconfigura o treemap
    return part + 1;
  }

  // Função que busca o nome do usuário pelo seu id
  var searchUser = function (userId, api) {
    // O retorno conterá apenas um elemento visto que um id só pode pertencer a um usuário
    return api.filter(function (item) {
      return item.id === userId;
    });
  }

  // Função usada para remover treemap antigo, caso houver
  var removeTremap = function (div) {
    $("#"+div +" > .chart").remove();
  }

  // Função usada para remover o relatório descritivo antigo, caso houver
  var removeReportDescription = function () {
    $("#report-description").remove();
    $("#report").remove();
  }

  var fillLegend = function () {
    $("svg > #gray").css("fill", color.gray);
    $("svg > #red").css("fill", color.red);
    $("svg > #orange").css("fill", color.orange);
    $("svg > #yellow").css("fill", color.yellow);
    $("svg > #green").css("fill", color.green);
    $("svg > #blue").css("fill", color.blue);
  }

  var reportDescription = function (form, data) {
      form.before($("<span/>", { id: "report-description", class: "concave-button", text: "Mostrar informações detalhadas" }));
      $("#report-description").click(function (){
          $("#report").slideToggle('fast');
      });

      form.before($("<table/>", { id: "report", class: "table-report-students" }));

      var report = $("#report");
      report.hide();
      report.append($("<tbody/>"));

      report.find("tbody").append($("<tr/>", { class: "row-head" }));
      report.find(".row-head").append($("<th/>", { class: "head", text: "Nome" }));
      report.find(".row-head").append($("<th/>", { class: "head", text: "Comentários" }));
      report.find(".row-head").append($("<th/>", { class: "head", text: "Resposta a comentários" }));
      report.find(".row-head").append($("<th/>", { class: "head", text: "Pedidos de ajuda" }));
      report.find(".row-head").append($("<th/>", { class: "head", text: "Resposta a pedidos de ajuda" }));
      report.find(".row-head").append($("<th/>", { class: "head", text: "Média dos exercícios" }));
      report.find(".row-head").append($("<th/>", { class: "head", text: "Link" }));

      $.each(data.children, function(index, object){
          report.find("tbody").append($("<tr/>",
                  { id: "" + object.id, class: "row" }));

          var row = report.find("#" + object.id);
          row.append($("<td/>", { class: "cell" }));
          row.find(".cell").append($("<div/>", { class: "student-info" }));

          var div = row.find(".student-info");
          div.append($("<span/>", { class: "student-name",
              text: object.name + " " + object.last_name }));

          row.append($("<td/>", { id: "activities", class: "cell" }));
          row.find("#activities").append($("<span/>",
                  { class: "participation", text: object.activities }));

          row.append($("<td/>", { id: "answered_activities", class: "cell" }));
          row.find("#answered_activities").append($("<span/>",
                  { class: "participation", text: object.answered_activities }));

          row.append($("<td/>", { id: "helps", class: "cell" }));
          row.find("#helps").append($("<span/>",
                  { class: "participation", text: object.helps }));

          row.append($("<td/>", { id: "answered_helps", class: "cell" }));
          row.find("#answered_helps").append($("<span/>",
                  { class: "participation", text: object.answered_helps }));

          row.append($("<td/>", { id: "grade", class: "cell" }));
          row.find("#grade").append($("<span/>",
                  { class: "participation",
                    text: object.grade === -1 ? "Não realizou" : object.grade }));

          row.append($("<td/>", { class: "cell treemap-link" }));
          row.find(".treemap-link").append($("<a/>",
                      { text: "no mapa", href: "#" + object.id }));

          row.find(".treemap-link").click(function(){
              $("rect").css("stroke-width", 0);
              $("g > #" + object.id).css("stroke-width", 5).
              css("stroke", "black");
          });
      });
  }

  // Função visível para a view, carregamento do treemap
  return {
   load: function (graphView) {
      //Preenche as cores da legenda
      fillLegend();

      // Inicializa o javascript do form
      var graph = graphView.form.plotGraphForm(graphView.renderTo);

      // Função para construção do treemap
      graph.loadGraph(function (jsonVis) {
        // Requisição para api precisa ser feita em busca do nome dos alunos
        $.ajax({
          url: graphView.url,
          method: "GET",
          success: function (jsonApi) {
            // remove treemap antigo
            removeTremap(graphView.renderTo);

            // Layout vazio do treemap
            var treemap = d3.layout.treemap()
              .round(false)
              .size([w, h])
              .sticky(true)
              .value(function(d) { return d.size; });

            // Div onde o treemap será carregado
            var svg = d3.select("#"+graphView.renderTo).append("div")
              .attr("class", "chart")
              .style("width", w + "px")
              .style("height", h + 54 + "px") // 54 é o tamanho da div do título do form
              .append("svg:svg")
              .attr("width", w)
              .attr("height", h)
              .append("svg:g")
              .attr("transform", "translate(.5,.5)");

            // Constrói o JSON característico do treemap usando os dados retornados das duas requisições
            root = buildJSON(jsonVis, jsonApi);

            // Carrega o treemap com o JSON montado
            var nodes = treemap.nodes(root)
              .filter(function(d) { return !d.children; });

            // Inicialização das células com seus atributos
            var cell = svg.selectAll("g")
              .data(nodes)
              .enter().append("svg:g")
              .attr("class", "cell")
              .attr("transform", function(d) { return "translate(" + d.x + "," + d.y + ")"; })
              .attr("alt", function (d) {
                var nota = d.grade !== -1 ? d.grade : "nenhum exercício realizado"
                return "Nome: " + d.name + " " + d.last_name
                        + "</br>Comentários: " + d.activities
                        + "</br>Pedidos de Ajuda: " + d.helps
                        + "</br>Respostas à comentários: " + d.answered_activities
                        + "</br>Respostas à pedidos de ajuda: " + d.answered_helps
                        + "</br>Nota: " + nota })

            // Cor
            cell.append("svg:rect")
              .attr("width", function(d) { return d.dx - 1; })
              .attr("height", function(d) { return d.dy - 1; })
              .attr("id", function (d) { return d.id; })
              .style("fill", function(d) { return fill(d.grade); })
              .on("click", function(){
                  $("rect").css("stroke-width", 0);
                  $(this).css("stroke-width", 5)
                  .css("stroke", "black");
              });

            // Texto
            cell.append("svg:text")
              .attr("x", function(d) { return d.dx / 2; })
              .attr("y", function(d) { return d.dy / 2; })
              .attr("dy", ".35em")
              .attr("text-anchor", "middle")
              .text(function(d) { return d.name; })
              .style("opacity", function(d) { d.w = this.getComputedTextLength(); return d.dx > d.w ? 1 : 0; });

            // Tooltip da célula
            $(".cell").tipTip({ defaultPosition: "left",
                                attribute: "alt" });

            // Relatório descritivo
            removeReportDescription();
            reportDescription(graphView.form, root);
          }
        })
      })
    }
  }
}
