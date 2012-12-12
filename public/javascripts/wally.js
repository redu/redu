(function(){
  if(!window.Redu){ window.Redu = {} }

  /**
  * Initializes the Wally App (through an iframe),
  * it also is responsible for resize the iframe
  * as needed by the Wally App.
  *
  * new Redu.Wally({
  *   remote: "http://mydomain.com",
  *   width: "500" //Initial width (optional)
  *   height: "200" //Initial height (optional)
  * })
  */
  window.Redu.Wally = function(opts){
    var wallyApp = this;
    this.container = $('.iframe-wally');
    this.defaultWidth = opts.width || 750;
    this.defaultHeight = opts.height || 90;
    this.socket = this.initSocket({
      remote: opts.remote,
      container: this.container
    });
  };

  window.Redu.Wally.prototype.iframe = function(){
    return this.container.find('iframe')
  }

  window.Redu.Wally.prototype.initSocket = function(opts){
    var wallyApp = this;
    var socket = new easyXDM.Socket({
      remote: opts.remote,
      container: wallyApp.container[0],
      props: {
        width: wallyApp.defaultWidth,
        height: wallyApp.defaultHeight
      },

      onMessage: function(message, origin){
        var json = JSON.parse(message);
        var originUri = wallyApp.parseUri(origin);
        var remoteUri = wallyApp.parseUri(this.remote);

        if(remoteUri.authority == originUri.authority){
          if (json.event == 'resize'){
            wallyApp.resizeIframe({
              height: json.payload.height,
              width: json.payload.width
            });
          }
        } else {
          throw new Error("Access denied for " + origin);
        }
      }
    });

    return socket;
  };

  window.Redu.Wally.prototype.resizeIframe = function(opts){
    var options = {
      height: this.defaultHeight,
      width: this.defaultWidth
    };
    $.extend(options, opts);

    this.iframe().height(options.height);
    this.iframe().width(options.width);
  };

  window.Redu.Wally.prototype.parseUri = function(str) {
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
})();
