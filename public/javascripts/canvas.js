$(document).ready(function(){
  window.Canvas = function(options){
    var canvas = this;

    this.expander = $(".expander");
    this.wrapper = $("#content");
    this.container = $(".iframe-canvas");
    this.openSign = "▶";
    this.closeSign = "◀";
    this.thresholdWidth = 740;
    this.normalHeight = 1000;
    this.maxWidth = 920;
    this.defaultWidth = 710;
    this.defaultHeight = 3000;

    this.socket = this.initSocket({
      remote : options.remote,
      container : this.container
    });
    this.bindExpander();
    this.preventFullcreenPropagation();
  }

  window.Canvas.prototype.bindExpander = function(){
    var canvas = this;
    canvas.expander.bind("click", function(e){
      canvas.wrapper.toggleClass("full");
      canvas.expander.show();
      canvas.toggleExpander();

      e.preventDefault();
    });
  }

  window.Canvas.prototype.preventFullcreenPropagation = function(){
    var canvas = this;
    $(document).ajaxComplete(function(){
      canvas.wrapper.removeClass("full");
    });
  }

  window.Canvas.prototype.toggleExpander = function(){
    var canvas = this,
        expander = canvas.expander,
        link = canvas.expander.find('a');

    if(canvas.expander.is(".open")){
      link.html(canvas.closeSign);
      expander.removeClass("open");
      expander.addClass("close");
    } else {
      link.html(canvas.openSign);
      expander.removeClass("close");
      expander.addClass("open");
    }
  }

  window.Canvas.prototype.fullscreen = function(){
    this.wrapper.addClass("full");
  }

  window.Canvas.prototype.normalScreen = function(){
    this.wrapper.removeClass("full");
  }

  window.Canvas.prototype.resize = function(options) {
    var canvas = this,
        intendWidth = parseInt(options.width) || canvas.thresholdWidth,
        intendHeight = parseInt(options.height) || canvas.normalHeight,
        iframe = canvas.container.find('iframe');

    // Normalizando largura
    if(intendWidth > canvas.maxWidth)
      intendWidth = canvas.maxWidth;
    if(intendWidth < canvas.thresholdWidth)
      intendWidth = canvas.thresholdWidth;
    if(intendWidth > canvas.thresholdWidth)
      intendWidth = canvas.maxWidth;

    iframe.width(intendWidth);
    iframe.height(intendHeight);

    // Usando modo fullscreen ou não, baseado na largura
    if(intendWidth > canvas.thresholdWidth)
      canvas.fullscreen();
    else
      canvas.normalScreen();
  }

  window.Canvas.prototype.initSocket = function(options){
    var canvas = this;
    var socket = new easyXDM.Socket({
      container : options.container[0],
      remote : options.remote,
      props : { width : canvas.defaultWidth, height: canvas.defaultHeight },
      onMessage : function(message, origin) {
        var remote = Canvas.parseUri(this.remote),
          actual = Canvas.parseUri(origin),
          message = JSON.parse(message);

        if(remote.authority === actual.authority) {
          // canvas.resize({ width: message.payload.width, height: message.payload.height });
        }
      }
    });
  }

  window.Canvas.parseUri = function(str) {
    var options = {
      strictMode: false,
      key: ["source","protocol","authority","userInfo","user","password",
      "host","port","relative","path","directory","file","query","anchor"],
      q:   {
        name:   "queryKey",
        parser: /(?:^|&)([^&=]*)=?([^&]*)/g
      },
      parser: {
        strict: /^(?:([^:\/?#]+):)?(?:\/\/((?:(([^:@]*)(?::([^:@]*))?)?@)?([^:\/?#]*)(?::(\d*))?))?((((?:[^?#\/]*\/)*)([^?#]*))(?:\?([^#]*))?(?:#(.*))?)/,
        loose:  /^(?:(?![^:@]+:[^:@\/]*@)([^:\/?#.]+):)?(?:\/\/)?((?:(([^:@]*)(?::([^:@]*))?)?@)?([^:\/?#]*)(?::(\d*))?)(((\/(?:[^?#](?![^?#\/]*\.[^?#\/.]+(?:[?#]|$)))*\/?)?([^?#\/]*))(?:\?([^#]*))?(?:#(.*))?)/
      }
    };

    var	o   = options,
        m   = o.parser[o.strictMode ? "strict" : "loose"].exec(str),
        uri = {},
        i   = 14;

    while (i--) uri[o.key[i]] = m[i] || "";

    uri[o.q.name] = {};
    uri[o.key[12]].replace(o.q.parser, function ($0, $1, $2) {
      if ($1) uri[o.q.name][$1] = $2;
    });

    return uri;
  }
});

