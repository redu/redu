// Código que torna o menu dos filtros fixo.
$(function() {

  var $win = $(window);

  var $landingfilters = $(".landing-filters");

  var landingfiltersFixed = 0;
  var landingfiltersTop = $(".landing-filters").length && $(".landing-filters").offset().top;

  var scrollLandingFilters = function() {
    var _, scrollTop = $win.scrollTop();
    if (scrollTop >= landingfiltersTop && !landingfiltersFixed) {
      landingfiltersFixed = 1;
      $landingfilters.addClass("page-nav-fixed");
    }
    else if (scrollTop <= landingfiltersTop && landingfiltersFixed) {
      landingfiltersFixed = 0;
      $landingfilters.removeClass("page-nav-fixed");
    }
  }

  scrollLandingFilters();

  $win.bind("scroll", scrollLandingFilters);

  $(".nav-global").each(function() {
    $(".landing-filters").css('marginTop', '42px')
  });
});
