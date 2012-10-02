// Deixa o menu dos filtros fixos
$(function() {

  var $win = $(window);

  var $landingFilters = $(".landing-filters");

  var landingFiltersFixed = 0;
  var landingFiltersTop = $landingFilters.length && $landingFilters.offset().top;

  var scrolllandingFilters = function() {
    var _, scrollTop = $win.scrollTop();
    if (scrollTop >= landingFiltersTop && !landingFiltersFixed) {
      landingFiltersFixed = 1;
      $landingFilters.addClass("landing-filters-fixed");
    }
    else if (scrollTop <= landingFiltersTop && landingFiltersFixed) {
      landingFiltersFixed = 0;
      $landingFilters.removeClass("landing-filters-fixed");
    }
  }

  // Faz com que o menu dos filtros fique com top e fixo, quando o usuário estiver logado.
  scrolllandingFilters();

  $win.bind("scroll", scrolllandingFilters);

  $(".nav-global").each(function() {
    $landingFilters.css('marginTop', '42px')
  });

  // Faz com que os títulos das navegações apareçam
  $(".filter, .landing-footer-navigation a").filter(function(index) {
    var anchorRegex = /^\/?#/
    return (anchorRegex.test($(this).attr('href')))
  }).click( function(event) {
    event.preventDefault();
    var offset = $($(this).attr('href').replace('/', '')).offset().top;
    var height = 120;

    if ($landingFilters.css('top') === "0px") {
      height = 60;
    }

    $('html, body').animate({scrollTop: (offset - height)}, 500);
  });
});
