$(document).ready(function(){
  $('.home-tour .modal').on('show', function () {
    $('body').css('overflow', 'hidden');
  });

  $('.home-tour .modal').on('hide', function () {
    $('body').css('overflow', 'auto');
  });

  $('#tour-1').on('show', function () {
    $("html, body").animate({ scrollTop: 0 }, "slow");
  });

  $('#tour-2').on('show', function () {
    $('.nav-global').css('z-index', 1060);
  });

  $('#tour-2').on('hide', function () {
    $('.nav-global').css('z-index', 1020);
  });

  $('#tour-3').on('show', function () {
    $('.nav-global').css('position', 'static');
    $('.nav-global').css('margin-bottom', '0');
    $('.main-wrapper').css('padding-top', '0');
    $('.nav-global-button-active').css('position', 'relative');
    $('.nav-global-button-active').css('z-index', 1060);
  });

  $('#tour-3').on('hide', function () {
    $('.nav-global-button-active').css('z-index', 1020);
    $('.nav-global').css('position', 'fixed');
    $('.nav-global').css('margin-bottom', '18px');
    $('.main-wrapper').css('padding-top', '42px');
  });

  $('#tour-4').on('show', function () {
    $('.nav-global').css('position', 'static');
    $('.nav-global').css('margin-bottom', '0');
    $('.main-wrapper').css('padding-top', '0');
    $('.nav-global-button[title="Ensine"]').css('position', 'relative');
    $('.nav-global-button[title="Ensine"]').css('z-index', 1060);
    $('.nav-global-button').css('background-color', '#F7F7F7');
    $('.nav-global-button').css('border-radius', '5px');
    $('.nav-global-button').css('-moz-border-radius', '5px');
  });

  $('#tour-4').on('hide', function () {
    $('.nav-global-button[title="Ensine"]').css('z-index', 1020);
    $('.nav-global').css('position', 'fixed');
    $('.nav-global').css('margin-bottom', '18px');
    $('.main-wrapper').css('padding-top', '42px');
    $('.nav-global-button').css('background-color', 'transparent');
  });

  $('#tour-5').on('show', function () {
    $('.nav-global').css('position', 'static');
    $('.nav-global').css('margin-bottom', '0');
    $('.main-wrapper').css('padding-top', '0');
    $('.nav-global-button[title="Cursos"]').css('position', 'relative');
    $('.nav-global-button[title="Cursos"]').css('z-index', 1060);
    $('.nav-global-button').css('background-color', '#F7F7F7');
    $('.nav-global-button').css('border-radius', '5px');
    $('.nav-global-button').css('-moz-border-radius', '5px');
  });

  $('#tour-5').on('hide', function () {
    $('.nav-global-button[title="Cursos"]').css('z-index', 1020);
    $('.nav-global').css('position', 'fixed');
    $('.nav-global').css('margin-bottom', '18px');
    $('.main-wrapper').css('padding-top', '42px');
    $('.nav-global-button').css('background-color', 'transparent');
  });

  $('#tour-6').on('show', function () {
    $('.nav-global').css('position', 'static');
    $('.nav-global').css('margin-bottom', '0');
    $('.main-wrapper').css('padding-top', '0');
    $('.nav-global-button[title="Aplicativos"]').css('position', 'relative');
    $('.nav-global-button[title="Aplicativos"]').css('z-index', 1060);
    $('.nav-global-button').css('background-color', '#F7F7F7');
    $('.nav-global-button').css('border-radius', '5px');
    $('.nav-global-button').css('-moz-border-radius', '5px');
  });

  $('#tour-6').on('hide', function () {
    $('.nav-global-button[title="Aplicativos"]').css('z-index', 1020);
    $('.nav-global').css('position', 'fixed');
    $('.nav-global').css('margin-bottom', '18px');
    $('.main-wrapper').css('padding-top', '42px');
    $('.nav-global-button').css('background-color', 'transparent');
  });

  $('#tour-7').on('show', function () {
    $('.nav-global').css('position', 'static');
    $('.nav-global').css('margin-bottom', '0');
    $('.main-wrapper').css('padding-top', '0');
    $('.nav-global-button-dropdown').css('position', 'relative');
    $('.nav-global-button-dropdown').css('z-index', 1060);
  });

  $('#tour-7').on('hide', function () {
    $('.nav-global-button-dropdown').css('z-index', 1020);
    $('.nav-global').css('position', 'fixed');
    $('.nav-global').css('margin-bottom', '18px');
    $('.main-wrapper').css('padding-top', '42px');
  });

  $('#tour-8').on('show', function () {
    $('.home-profile-area-photo').css('position', 'relative');
    $('.home-profile-area-photo').css('z-index', 1060);
  });

  $('#tour-8').on('hide', function () {
    $('.home-profile-area-photo').css('z-index', 1000);
  });

  $('#tour-9').on('show', function () {
    $('.nav-local').css('position', 'relative');
    $('.nav-local').css('z-index', 1060);
    $('.nav-local').css('background-color', '#F7F7F7');
    $('.nav-local').css('border-radius', '5px');
    $('.nav-local').css('-moz-border-radius', '5px');
  });

  $('#tour-9').on('hide', function () {
    $('.nav-local').css('z-index', 1000);
    $('.nav-local').css('background-color', 'transparent');
  });

  $('#tour-10').on('show', function () {
    $('.nav-local').css('z-index', 'auto');
    $('.nav-local-item-active').css('position', 'relative');
    $('.nav-local-item-active').css('z-index', 1060);
  });

  $('#tour-10').on('hide', function () {
    $('.nav-local-item-active').css('z-index', 1000);
  });

  $('#tour-11').on('show', function () {
    var position = $('#home-invite-friends').position();
    $(this).css('top', position.top - 50);
    $(this).css('left', position.left - 360);
    $('#home-invite-friends').css('position', 'relative');
    $('#home-invite-friends').css('z-index', 1060);
    $('#home-invite-friends').css('background-color', '#F7F7F7');
    $('#home-invite-friends').css('border-radius', '5px');
    $('#home-invite-friends').css('-moz-border-radius', '5px');
  });

  $('#tour-11').on('hide', function () {
    $('#home-invite-friends').css('z-index', 1000);
    $('#home-invite-friends').css('background-color', 'none');
  });

  $('#tour-12').on('show', function () {
    $('#habla_window_div').css('cssText', 'margin: 0px 20px; bottom: 0px; right: 0px; display: none; position: fixed; z-index: 1600 !important;');
  });

  $('#tour-12').on('hide', function () {
    $('#habla_window_div').css('cssText', 'margin: 0px 20px; bottom: 0px; right: 0px; display: none; position: fixed;');
  });

  $('#tour-13').on('show', function () {
    $('#chat').css('z-index', 1060);
  });

  $('#tour-13').on('hide', function () {
    $('#chat').css('z-index', 1000);
  });

  /* Envia requisição para identificar itens como explorados
   *
   * Caso o elemento possua um href com url para outro domínio,
   * o usuário só será redirecionado após o final da requisição.
   *
   * O identificador do elemento do tour será o do attributo data-tour;
   * caso este não tenha sido especificado, será o href do elemento após
   * a retirada do #.
   */
  $.fn.exploreTour = function(url){
    return this.each(function(){
      var $this = $(this);
      $this.click(function(){
        var dataTour = $this.attr('data-tour');
        var href =  $this.attr('href');

        if (href && href.indexOf('http://') != -1) {
          $.post(url, { id : dataTour } , function(){
            window.location = href;
          });

          return false;
        } else {
          var identifier = dataTour || href.split("#")[1];
          $.post(url, { id : identifier });
        }
      });
    });
  };
});
