var SpaceTreemap = function () {
  var w = 748,
      h = 400,
      x = d3.scale.linear().range([0, w]),
      y = d3.scale.linear().range([0, h]),
      color = [d3.rgb(193,39,45), d3.rgb(243,94,0),
      d3.rgb(255,200,0), d3.rgb(95,192,128), d3.rgb(77,173,214)],
      // Vermelho, Laranja, Amarelo, Verde, Azul
      root,
      node;

  var treemap = d3.layout.treemap()
    .round(false)
    .size([w, h])
    .sticky(true)
    .value(function(d) { return d.size; });

  var svg = d3.select(".panel").append("div")
    .attr("class", "chart")
    .style("width", w + "px")
    .style("height", h + "px")
    .append("svg:svg")
    .attr("width", w)
    .attr("height", h)
    .append("svg:g")
    .attr("transform", "translate(.5,.5)");

  d3.json("http://localhost:3000/vis/dashboard/flare.json", function(data) {
    node = root = buildJSON(data, data);

    var nodes = treemap.nodes(root)
    .filter(function(d) { return !d.children; });

    var cell = svg.selectAll("g")
      .data(nodes)
     .enter().append("svg:g")
      .attr("class", "cell")
      .attr("transform", function(d) { return "translate(" + d.x + "," + d.y + ")"; })
      .attr("title", function (d) { return d.name })

    cell.append("svg:rect")
      .attr("width", function(d) { return d.dx - 1; })
      .attr("height", function(d) { return d.dy - 1; })
      .style("fill", function(d) { return fill(d.grade); });

    cell.append("svg:text")
      .attr("x", function(d) { return d.dx / 2; })
      .attr("y", function(d) { return d.dy / 2; })
      .attr("dy", ".35em")
      .attr("text-anchor", "middle")
      .text(function(d) { return d.name; })
      .style("opacity", function(d) { d.w = this.getComputedTextLength(); return d.dx > d.w ? 1 : 0; });

    $(".cell").tipTip();
  });

  var fill = function (grade){
    if (grade < -1.0) {
      return white;
    }
    else if (grade < 5.0) {
      if (grade < 3.0) {
        return color[0]
      }
      else{
        return color[1]
      };
    }
    else{
      if(grade < 7.0){
        return color[2]
      }
      else if (grade < 9.0) {
        return color[3]
      }
      else{
        return color[4]
      };
    };
  }

  var size = function (d) {
    return d.size;
  }

  var loadTreemap = function (spaceId, urlVis, urlApi) {
    var url = urlVis + "?space_id=" + spaceId;

    // Requisição via AJAX puro para que funcione em todos os browsers
    $.ajax({
      cache: false,
      crossDomain: true,
      url: url,
      method: "GET",
      dataType: 'jsonp',
      success: function (jsonVis) {

        url = urlApi;

        $.ajax({
          cache: false,
          crossDomain: true,
          url: url,
          method: "GET",
          dataType: 'jsonp',
          success: function (jsonApi) {
            data = buildJSON(jsonVis, jsonApi);
            node = root = data;

            var nodes = treemap.nodes(root)
              .filter(function(d) { return !d.children; });

            var cell = svg.selectAll("g")
              .data(nodes)
              .enter().append("svg:g")
              .attr("class", "cell")
              .attr("transform", function(d) { return "translate(" + d.x + "," + d.y + ")"; })

            cell.append("svg:rect")
              .attr("width", function(d) { return d.dx - 1; })
              .attr("height", function(d) { return d.dy - 1; })
              .style("fill", function(d) { return fill(d.grade); });

            cell.append("svg:text")
              .attr("x", function(d) { return d.dx / 2; })
              .attr("y", function(d) { return d.dy / 2; })
              .attr("dy", ".35em")
              .attr("text-anchor", "middle")
              .text(function(d) { return d.name; })
              .style("opacity", function(d) { d.w = this.getComputedTextLength(); return d.dx > d.w ? 1 : 0; });
          }
        })
      }
    })
  }

  var buildJSON = function (vis, api) {
    var json = {"name": "treemap",
                "children": []};

    api = [{
      "id": 1,
        "last_name": "User",
        "birthday": "1992-02-29",
        "links": [{
          "href": "http://127.0.0.1:3000/api/users/test_user",
          "rel": "self"
        }, {
          "href": "http://127.0.0.1:3000/api/users/test_user/enrollments",
          "rel": "enrollments"
        }],
        "login": "test_user",
        "friends_count": 0,
        "email": "test_user@example.com",
        "first_name": "Test"
    }, {
      "id": 3,
        "last_name": "Cavalcanti",
        "birthday": "1987-03-06",
        "links": [{
          "href": "http://127.0.0.1:3000/api/users/guiocavalcanti",
          "rel": "self"
        }, {
          "href": "http://127.0.0.1:3000/api/users/guiocavalcanti/enrollments",
          "rel": "enrollments"
        }],
        "login": "guiocavalcanti",
        "friends_count": 0,
        "email": "guiocavalcanti@gmail.com",
        "first_name": "Guilherme"
    }]

    $.each(vis.children, function (index, object) {
      var item = {};
      var user = searchUser(1,api)[0];
      item.name = user.first_name + " " + user.last_name;
      item.size = object.size;
      item.grade = object.grade;

      json.children.push(item);
    })

    return json;
  }

  var searchUser = function (user, api) {
    return api.filter(function (item) {
      return item.id === user;
    });
  }

  return {
    load: function (spaceId, url) {
      loadTreemap(spaceId, url);
    }
  }
}
