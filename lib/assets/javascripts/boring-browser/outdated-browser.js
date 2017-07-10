jQuery(function(){
    $.verifyCompatibleBrowser();
});

/* Verifica se o browser é compatível e esconde o aviso, caso seja. */
$.verifyCompatibleBrowser = function(){
  var myBrowser = $.browserInfos();
  var minVersion = 0; // Para o caso de ser um browser não usual

  if (myBrowser.isChrome()) {
    minVersion = 11;
  }else if(myBrowser.isSafari()){
    minVersion = 4;
  }else if(myBrowser.isOpera()){
    minVersion = 11;
  }else if(myBrowser.isFirefox()){
    minVersion = 3.6;
  }else if (myBrowser.isIE()){
    minVersion = 9;
  }

  var warned = $.cookie("boring_browser");
  if(!warned && !(myBrowser.version >= minVersion)){
    $("#outdated-browser").show();
  }

  $("#outdated-browser .close").click(function(){
      $.cookie("boring_browser", true, { path: "/" });
      $("#outdated-browser").fadeOut();
  });
};
