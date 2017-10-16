$(function() {
  // Expande todas as respostas.
  var $responses = $(".responses").children();
  $responses.slideDown(150, "swing");
  $responses.first().hide();
  $responses.first().next().find("hr").remove();
  $responses.last().hide();
});
