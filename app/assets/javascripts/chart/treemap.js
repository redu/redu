var StudentsTreemap = function() {
  // Configurações do layout do treemap
  var w = 718,
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

  // Função para preenchimento das cores da células, se grade = -1 preenchimento neutro
  var fill = function(grade) {
    if (grade === -1.0) {
      return color.gray;
    }
    else if (grade < 5.0) {
      if (grade < 3.0) {
        return color.red;
      }
      else {
        return color.orange;
      }
    }
    else {
      if(grade < 7.0) {
        return color.yellow;
      }
      else if (grade < 9.0) {
        return color.green;
      }
      else {
        return color.blue;
      };
    };
  }

  // Função que retorna o tamanho da célula proveniente do JSON
  var size = function(d) {
    return d.size;
  }

  // Função para construção padrão do JSON do treemap
  var buildJSON = function(vis, api) {
    // JSON conterá apenas um nó pai com seus filhos
    var json = {"name": "treemap",
                "children": []};

    // Para cada aluno do Space eu monto um filho padrão do treemap
    $.each(vis, function(index, object) {
      var item = {};

      // Busca o nome do aluno nos dados da API
      var user = searchUser(vis[index].user_id, api);
      if (user) {
        // Informações básicas do aluno
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

    // Filtra os filhos para que só mostrem os membros (alunos) da disciplina
    json.children = json.children.filter(function(child) { return child.name; });
    return json;
  }

  // Função de participação do aluno, baseado em suas atividades na Disciplina
  var participation = function(data) {
    var part = data.helps + data.activities +
      data.answered_activities + data.answered_helps;

    // O size não pode ser zero pois desconfigura o treemap
    return part + 1;
  }

  // Função que busca o nome do usuário pelo seu id
  var searchUser = function(userId, api) {
    // O retorno conterá apenas um elemento visto que um id só pode pertencer a um usuário
    var response = api.filter(function(item) {
      return item.user.id === userId;
    });

    // Se houver resposta, retorna o usuário
    if (response[0]) {
      return response[0].user;
    }

    return response;
  }

  // Função usada para remover treemap antigo, caso houver
  var removeTremap = function(div) {
    $("#"+div +" > .chart").remove();
  }

  // Função usada para remover o relatório descritivo antigo, caso houver
  var removeReportDescription = function() {
    $(".report-show-details, .report-table, .report-print").remove();
  }

  var fillLegend = function() {
    $(".report-legend-gray").css("fill", color.gray);
    $(".report-legend-red").css("fill", color.red);
    $(".report-legend-orange").css("fill", color.orange);
    $(".report-legend-yellow").css("fill", color.yellow);
    $(".report-legend-green").css("fill", color.green);
    $(".report-legend-blue").css("fill", color.blue);
  }

  var reportDescription = function(form, data, print, url) {
      $("<button/>", { "class": "report-show-details button-primary", "text": "Mostrar informações detalhadas" })
        .click(function() {
          $(".report-table, .report-print").slideToggle(150, "swing");
        })
        .insertBefore(form);

      var report = $("<div class='report-table'><table class='table-with-borderradius'><thead><tr><th>Nome</th><th>Comentários</th><th>Resposta a comentários</th><th>Pedidos de ajuda</th><th>Resposta a pedidos de ajuda</th><th>Média dos exercícios</th></thead><tbody></tbody></table></div>")
        .insertBefore(form);

      if (!print){
        report.find("thead tr").append($("<th/>", { "text": "Link" }));
        report.css('max-height', '500px').css('overflow', 'auto');
      }

      data.children.sort(compare);

      // Template
      var table = "<% _.each(_.extend(children, print), function(object){ %>" +
            "<tr>" +
                "<td><%= object.name + ' ' + object.last_name %></td>" +
                "<td class='text-center'><%= object.activities %></td>" +
                "<td class='text-center'><%= object.answered_activities %></td>" +
                "<td class='text-center'><%= object.helps %></td>" +
                "<td class='text-center'><%= object.answered_activities %></td>" +
                "<td class='text-center'><%= object.grade === -1 ? 'Não realizou' : object.grade %></td>" +
                "<% if (!print) { %>" +
                    "<td class='text-center treemap-link'>" +
                        "<a href=#<%=object.id%>>no mapa</a>" +
                    "</td>" +
                "<% };%>" +
            "</tr>" +
          "<% }); %>"

      report.find("tbody").append(_.template(table, _.extend(data, { print: print })));

      $(".treemap-link").click(function(){
          $("rect").css("stroke-width", 0);
          $("g > #" + $(this).find("a")[0].href.split("#")[1]).css("stroke-width", 5).
          css("stroke", "black");
      });

      $("<a/>", { "class": "report-print button-primary", "text": "Imprimir", href: url })
        .insertAfter(report)
        .click(function() {
          var start = timeSelected("start");
          var end = timeSelected("end");

          $(this).attr("href", url + "?date_start=" + start + "&date_end=" + end);
        });
  }

  function compare(a,b) {
      if ((a.name + " " + a.last_name).toUpperCase() < (b.name + " " + a.last_name).toUpperCase())
          return -1;
      if ((a.name + " " + a.last_name).toUpperCase() > (b.name + " " + a.last_name).toUpperCase())
          return 1;
      return 0;
  }

  var timeSelected = function(period) {
    select = $("#date_"+period+"_fake__3i");
    var day = select[0].options[select[0].selectedIndex].value;
    select = $("#date_"+period+"_fake__2i");
    var month = select[0].options[select[0].selectedIndex].value;
    select = $("#date_"+period+"_fake__1i");
    var year = select[0].options[select[0].selectedIndex].value;
    return year + "-" + month + "-" + day;
  };

  // Função visível para a view, carregamento do treemap
  return {
   load: function(graphView) {
      //Preenche as cores da legenda
      fillLegend();

      // Inicializa o javascript do form
      var graph = graphView.form.plotGraphForm(graphView.renderTo);

      // Função para construção do treemap
      graph.loadGraph(function(jsonVis) {
        // Requisição para api precisa ser feita em busca do nome dos alunos
        $.ajax({
          url: graphView.url,
          method: "GET",
          success: function(jsonApi) {
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
              .attr("transform", function(d) { return "translate(" + d.x + "," + d.y + ")"; })
              .attr("rel", "tooltip")
              .attr("data-placement", "left")
              .attr("title", function(d) {
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
              .attr("id", function(d) { return d.id; })
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

            // Relatório descritivo
            removeReportDescription();
            reportDescription(graphView.form, root, false, graphView.print);
          } // Success end
        }) // Ajax en
      }) // LoadGraph end
    }, // Load end
   print: function(graphView) {
      $("#graph-form").hide();

      // Inicializa o javascript do form
      var graph = graphView.form.plotGraphForm(graphView.renderTo);
      graph.loadGraph(function(jsonVis) {
        // Requisição para api precisa ser feita em busca do nome dos alunos
        $.ajax({
          url: graphView.url,
          method: "GET",
          success: function(jsonApi) {
            // Constrói o JSON característico do treemap usando os dados retornados das duas requisições
            root = buildJSON(jsonVis, jsonApi);

            // Relatório descritivo
            removeReportDescription();
            reportDescription(graphView.form, root, true);

            $(".report-table").show();
            $("#treemap-chart").hide();
            $(".report-show-details").hide();
            $(".report-print").hide();
            }
        })
      })
    } // Print end
  } // Return end
} // StudentsTreemap end
