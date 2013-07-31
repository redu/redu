//= require rails
//= require modernizr
//= require jquery.autosize.min
//= require placeholder-polyfill
//= require bootstrap/bootstrap-redu

$(document).ajaxComplete(function() {
  $(".tooltip").remove();
  $('[rel="tooltip"]').tooltip();
});