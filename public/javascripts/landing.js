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
      $landingFilters.addClass("page-nav-fixed");
    }
    else if (scrollTop <= landingFiltersTop && landingFiltersFixed) {
      landingFiltersFixed = 0;
      $landingFilters.removeClass("page-nav-fixed");
    }
  }

  // Faz com que o menu dos filtros fique com top e fixo, quando o usuário estiver logado.
  scrolllandingFilters();

  $win.bind("scroll", scrolllandingFilters);

  $(".nav-global").each(function() {
    $landingFilters.css('marginTop', '42px')
  });

  // Faz com que os títulos das navegações apareçam
  $(".filter").click( function(event) {
    event.preventDefault();
    var offset = $($(this).attr('href')).offset().top;
    var height = 175;

    if ($landingFilters.css('top') === "0px") {
      height = 85;
    }

    $('html, body').animate({scrollTop: (offset - height)}, 500);
  });
});
