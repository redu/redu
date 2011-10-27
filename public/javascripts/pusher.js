/*!
 * Pusher JavaScript Library v1.9.4
 * http://pusherapp.com/
 *
 * Copyright 2011, Pusher
 * Released under the MIT licence.
 */

if (typeof Function.prototype.scopedTo === 'undefined') {
  Function.prototype.scopedTo = function(context, args) {
    var f = this;
    return function() {
      return f.apply(context, Array.prototype.slice.call(args || [])
        .concat(Array.prototype.slice.call(arguments)));
    };
  };
}

var Pusher = function(app_key, options) {
  this.options = options || {};
  this.path = '/app/' + app_key + '?client=js&version=' + Pusher.VERSION;
  this.key = app_key;
  this.channels = new Pusher.Channels();
  this.global_channel = new Pusher.Channel('pusher_global_channel');
  this.global_channel.global = true;

  var self = this;

  this.connection = new Pusher.Connection(this.key, this.options);

  // Setup / teardown connection
  this.connection
    .bind('connected', function() {
      self.subscribeAll();
    })
    .bind('message', function(params) {
      self.send_local_event(params.event, params.data, params.channel);
    })
    .bind('disconnected', function() {
      self.channels.disconnect();
    })
    .bind('error', function(err) {
      Pusher.debug('Error', err);
    });

  Pusher.instances.push(this);

  if (Pusher.isReady) self.connect();
};
Pusher.instances = [];
Pusher.prototype = {
  channel: function(name) {
    return this.channels.find(name);
  },

  connect: function() {
    this.connection.connect();
  },

  disconnect: function() {
    Pusher.debug('Disconnecting');
    this.connection.disconnect();
  },

  bind: function(event_name, callback) {
    this.global_channel.bind(event_name, callback);
    return this;
  },

  bind_all: function(callback) {
    this.global_channel.bind_all(callback);
    return this;
  },

  subscribeAll: function() {
    var channel;
    var channelNames = [];
    for (channel in this.channels.channels) {
      if (this.channels.channels.hasOwnProperty(channel)) {
        channelNames.push(channel);
      }
    }
    this.multiSubscribe(channelNames);
  },

  subscribe: function(channel_name) {
    var self = this;
    var channel = this.channels.add(channel_name, this);
    if (this.connection.state === 'connected') {
      channel.authorize(this, function(err, data) {
        if (err) {
          channel.emit('subscription_error', data);
        } else {
          self.send_event('pusher:subscribe', {
            channel: channel_name,
            auth: data.auth,
            channel_data: data.channel_data
          });
        }
      });
    }
    return channel;
  },

  unsubscribe: function(channel_name) {
    this.channels.remove(channel_name);
    if (this.connection.state === 'connected') {
      this.send_event('pusher:unsubscribe', {
        channel: channel_name
      });
    }
  },

  send_event: function(event_name, data, channel) {
    Pusher.debug("Event sent (channel,event,data)", channel, event_name, data);

    var payload = {
      event: event_name,
      data: data
    };
    if (channel) payload['channel'] = channel;

    this.connection.send(JSON.stringify(payload));
    return this;
  },

  send_local_event: function(event_name, event_data, channel_name) {
    event_data = Pusher.data_decorator(event_name, event_data);
    if (channel_name) {
      var channel = this.channel(channel_name);
      if (channel) {
        channel.dispatch_with_all(event_name, event_data);
      }
    } else {
      // Bit hacky but these events won't get logged otherwise
      Pusher.debug("Event recd (event,data)", event_name, event_data);
    }

    this.global_channel.dispatch_with_all(event_name, event_data);
  },
  /**
   * Subscribe to multiple channels in one call. The underlying authentication request, if required.
   * is also performed using a single call.
   *
   * @return a map of channel names to channel objects.
   *
   * @example
   * var pusher = new Pusher("APP_KEY");
   * var channels = pusher.multiSubscribe(['private-channel1', 'private-channel2']);
   * var channel1 = channels['private-channel1'];
   */
  multiSubscribe: function(channels) {
    var self = this;
    var channelName;
    var channel;
    var newChannels = {};
    for(var i = 0, l = channels.length; i < l; ++i) {
      channelName = channels[i];
      channel = this.channels.add(channelName, this);
      newChannels[channelName] = channel;
    }

    if (this.connection.state === 'connected') {
      this._multiAuth(channels, function(err, authData) {
        if (err) {
          channel.emit('subscription_error', authData);
        } else {
          self._sendSubscriptionEvents(channels, authData);
        }
      });
    }

    return newChannels;
  },

  /** @private */
  _multiAuth: function(channels, callback) {
    var self = this;

    var xhr = window.XMLHttpRequest ?
      new XMLHttpRequest() :
      new ActiveXObject("Microsoft.XMLHTTP");
    xhr.open("POST", Pusher.channel_multiauth_endpoint, true);
    xhr.setRequestHeader("Content-Type", "application/json")
    xhr.onreadystatechange = function() {
      if (xhr.readyState == 4) {
        if (xhr.status == 200) {
          var data = JSON.parse(xhr.responseText);
          callback(false, data);
        } else {
          Pusher.debug("Couldn't get multiauth info from your webapp", status);
          callback(true, xhr.status);
        }
      }
    };

    var channelsToAuthorize = this._filterAuthChannels(channels);
    var authRequest = {
      socket_id: self.connection.socket_id,
      channels: channelsToAuthorize
    };
    var postData = JSON.stringify(authRequest);
    xhr.send(postData);
  },

  /** @private */
  _filterAuthChannels: function(channels) {
    var channelsToAuth = [];
    var channelName;
    for(var i = 0, l = channels.length; i < l; ++i) {
      channelName = channels[i];
      if(Pusher.Util.startsWith(channelName, 'private-') ||
        Pusher.Util.startsWith(channelName, 'presence-') ) {
        channelsToAuth.push(channelName);
      }
    }
    return channelsToAuth;
  },

  /** @private */
  _sendSubscriptionEvents: function(channels, authData) {
    var channelName;
    var channelAuth;
    for(var i = 0, l = channels.length; i < l; ++i) {
      channelName = channels[i];
      channelAuth = authData[channelName] || {};
      this.send_event('pusher:subscribe', {
        channel: channelName,
        auth: channelAuth.auth,
        channel_data: channelAuth.channel_data
      }, channelName);
    }
  }
};

Pusher.Util = {
  extend: function extend(target, extensions) {
    for (var property in extensions) {
      if (extensions[property] && extensions[property].constructor &&
        extensions[property].constructor === Object) {
        target[property] = extend(target[property] || {}, extensions[property]);
      } else {
        target[property] = extensions[property];
      }
    }
    return target;
  },
  startsWith: function(check, startsWith){
    return (check.indexOf(startsWith) === 0);
  }
};

// To receive log output provide a Pusher.log function, for example
// Pusher.log = function(m){console.log(m)}
Pusher.debug = function() {
  if (!Pusher.log) { return }
  var m = ["Pusher"]
  for (var i = 0; i < arguments.length; i++){
    if (typeof arguments[i] === "string") {
      m.push(arguments[i])
    } else {
      if (window['JSON'] == undefined) {
        m.push(arguments[i].toString());
      } else {
        m.push(JSON.stringify(arguments[i]))
      }
    }
  };
  Pusher.log(m.join(" : "))
}

// Pusher defaults
Pusher.VERSION = '1.9.4';

Pusher.host = 'ws.pusherapp.com';
Pusher.ws_port = 80;
Pusher.wss_port = 443;
Pusher.channel_auth_endpoint = '/pusher/auth';
Pusher.channel_multiauth_endpoint = '/pusher/multiauth';
Pusher.connection_timeout = 5000;
Pusher.presence_timeout = 10000;
Pusher.cdn_http = 'http://js.pusherapp.com/'
Pusher.cdn_https = 'https://d3ds63zw57jt09.cloudfront.net/'
Pusher.data_decorator = function(event_name, event_data){ return event_data }; // wrap event_data before dispatching
Pusher.allow_reconnect = true;
Pusher.channel_auth_transport = 'ajax';

Pusher.isReady = false;
Pusher.ready = function() {
  Pusher.isReady = true;
  for (var i = 0, l = Pusher.instances.length; i < l; i++) {
    Pusher.instances[i].connect();
  }
};

;(function() {
/* Abstract event binding
Example:

    var MyEventEmitter = function(){};
    MyEventEmitter.prototype = new Pusher.EventsDispatcher;

    var emitter = new MyEventEmitter();

    // Bind to single event
    emitter.bind('foo_event', function(data){ alert(data)} );

    // Bind to all
    emitter.bind_all(function(event_name, data){ alert(data) });

--------------------------------------------------------*/
  function EventsDispatcher() {
    this.callbacks = {};
    this.global_callbacks = [];
  }

  EventsDispatcher.prototype.bind = function(event_name, callback) {
    this.callbacks[event_name] = this.callbacks[event_name] || [];
    this.callbacks[event_name].push(callback);
    return this;// chainable
  };

  EventsDispatcher.prototype.emit = function(event_name, data) {
    this.dispatch_global_callbacks(event_name, data);
    this.dispatch(event_name, data);
    return this;
  };

  EventsDispatcher.prototype.bind_all = function(callback) {
    this.global_callbacks.push(callback);
    return this;
  };

  EventsDispatcher.prototype.dispatch = function(event_name, event_data) {
    var callbacks = this.callbacks[event_name];

    if (callbacks) {
      for (var i = 0; i < callbacks.length; i++) {
        callbacks[i](event_data);
      }
    } else {
      // Log is un-necessary in case of global channel or connection object
      if (!(this.global || this instanceof Pusher.Connection || this instanceof Pusher.Machine)) {
        Pusher.debug('No callbacks for ' + event_name, event_data);
      }
    }
  };

  EventsDispatcher.prototype.dispatch_global_callbacks = function(event_name, data) {
    for (var i = 0; i < this.global_callbacks.length; i++) {
      this.global_callbacks[i](event_name, data);
    }
  };

  EventsDispatcher.prototype.dispatch_with_all = function(event_name, data) {
    this.dispatch(event_name, data);
    this.dispatch_global_callbacks(event_name, data);
  };

  this.Pusher.EventsDispatcher = EventsDispatcher;
}).call(this);

;(function() {
  var Pusher = this.Pusher;

  /*-----------------------------------------------
    Helpers:
  -----------------------------------------------*/

  // MSIE doesn't have array.indexOf
  var nativeIndexOf = Array.prototype.indexOf;
  function indexOf(array, item) {
    if (array == null) return -1;
    if (nativeIndexOf && array.indexOf === nativeIndexOf) return array.indexOf(item);
    for (i = 0, l = array.length; i < l; i++) if (array[i] === item) return i;
    return -1;
  }


  function capitalize(str) {
    return str.substr(0, 1).toUpperCase() + str.substr(1);
  }


  function safeCall(method, obj, data) {
    if (obj[method] !== undefined) {
      obj[method](data);
    }
  }

  /*-----------------------------------------------
    The State Machine
  -----------------------------------------------*/
  function Machine(actor, initialState, transitions, stateActions) {
    Pusher.EventsDispatcher.call(this);

    this.actor = actor;
    this.state = undefined;
    this.errors = [];

    // functions for each state
    this.stateActions = stateActions;

    // set up the transitions
    this.transitions = transitions;

    this.transition(initialState);
  };

  Machine.prototype.transition = function(nextState, data) {
    var prevState = this.state;
    var stateCallbacks = this.stateActions;

    if (prevState && (indexOf(this.transitions[prevState], nextState) == -1)) {
      throw new Error(this.actor.key + ': Invalid transition [' + prevState + ' to ' + nextState + ']');
    }

    // exit
    safeCall(prevState + 'Exit', stateCallbacks, data);

    // tween
    safeCall(prevState + 'To' + capitalize(nextState), stateCallbacks, data);

    // pre
    safeCall(nextState + 'Pre', stateCallbacks, data);

    // change state:
    this.state = nextState;

    // handy to bind to
    this.emit('state_change', {
      oldState: prevState,
      newState: nextState
    });

    // Post:
    safeCall(nextState + 'Post', stateCallbacks, data);
  };

  Machine.prototype.is = function(state) {
    return this.state === state;
  };

  Machine.prototype.isNot = function(state) {
    return this.state !== state;
  };

  Pusher.Util.extend(Machine.prototype, Pusher.EventsDispatcher.prototype);

  this.Pusher.Machine = Machine;
}).call(this);

;(function() {
  var Pusher = this.Pusher;

  var machineTransitions = {
    'initialized': ['waiting', 'failed'],
    'waiting': ['connecting', 'permanentlyClosed'],
    'connecting': ['open', 'permanentlyClosing', 'impermanentlyClosing', 'waiting'],
    'open': ['connected', 'permanentlyClosing', 'impermanentlyClosing', 'waiting'],
    'connected': ['permanentlyClosing', 'impermanentlyClosing', 'waiting'],
    'impermanentlyClosing': ['waiting', 'permanentlyClosing'],
    'permanentlyClosing': ['permanentlyClosed'],
    'permanentlyClosed': ['waiting']
  };


  // Amount to add to time between connection attemtpts per failed attempt.
  var UNSUCCESSFUL_CONNECTION_ATTEMPT_ADDITIONAL_WAIT = 2000;
  var UNSUCCESSFUL_OPEN_ATTEMPT_ADDITIONAL_TIMEOUT = 2000;
  var UNSUCCESSFUL_CONNECTED_ATTEMPT_ADDITIONAL_TIMEOUT = 2000;

  var MAX_CONNECTION_ATTEMPT_WAIT = 5 * UNSUCCESSFUL_CONNECTION_ATTEMPT_ADDITIONAL_WAIT;
  var MAX_OPEN_ATTEMPT_TIMEOUT = 5 * UNSUCCESSFUL_OPEN_ATTEMPT_ADDITIONAL_TIMEOUT;
  var MAX_CONNECTED_ATTEMPT_TIMEOUT = 5 * UNSUCCESSFUL_CONNECTED_ATTEMPT_ADDITIONAL_TIMEOUT;

  function resetConnectionParameters(connection) {
    connection.connectionWait = 0;

    if (Pusher.TransportType === 'flash') {
      // Flash needs a bit more time
      connection.openTimeout = 5000;
    } else {
      connection.openTimeout = 2000;
    }
    connection.connectedTimeout = 2000;
    connection.connectionSecure = connection.compulsorySecure;
    connection.connectionAttempts = 0;
  }

  function Connection(key, options) {
    var self = this;

    Pusher.EventsDispatcher.call(this);

    this.options = Pusher.Util.extend({encrypted: false}, options || {});

    this.netInfo = new Pusher.NetInfo();
    Pusher.EventsDispatcher.call(this.netInfo);

    // define the state machine that runs the connection
    this._machine = new Pusher.Machine(self, 'initialized', machineTransitions, {

      // TODO: Use the constructor for this.
      initializedPre: function() {
        self.compulsorySecure = self.options.encrypted;

        self.key = key;
        self.socket = null;
        self.socket_id = null;

        self.state = 'initialized';
      },

      waitingPre: function() {
        self._waitingTimer = setTimeout(function() {
          self._machine.transition('connecting');
        }, self.connectionWait);

        if (self.connectionWait > 0) {
          informUser('connecting_in', self.connectionWait);
        }

        if (netInfoSaysOffline() || self.connectionAttempts > 4) {
          if(netInfoSaysOffline())
          {
            // called by some browsers upon reconnection to router
            self.netInfo.bind('online', function() {
              if(self._machine.is('waiting'))
                self._machine.transition('connecting');
            });
          }

          triggerStateChange('unavailable');
        } else {
          triggerStateChange('connecting');
        }
      },

      waitingExit: function() {
        clearTimeout(self._waitingTimer);
      },

      connectingPre: function() {
        // removed: if not closed, something is wrong that we should fix
        // if(self.socket !== undefined) self.socket.close();
        var url = formatURL(self.key, self.connectionSecure);
        Pusher.debug('Connecting', url);
        self.socket = new Pusher.Transport(url);
        // now that the socket connection attempt has been started,
        // set up the callbacks fired by the socket for different outcomes
        self.socket.onopen = ws_onopen;
        self.socket.onclose = transitionToWaiting;
        self.socket.onerror = ws_onError;

        // allow time to get ws_onOpen, otherwise close socket and try again
        self._connectingTimer = setTimeout(TransitionToImpermanentClosing, self.openTimeout);
      },

      connectingExit: function() {
        clearTimeout(self._connectingTimer);
      },

      connectingToWaiting: function() {
        updateConnectionParameters();

        // FUTURE: update only ssl
      },

      connectingToImpermanentlyClosing: function() {
        updateConnectionParameters();

        // FUTURE: update only timeout
      },

      openPre: function() {
        self.socket.onmessage = ws_onMessage;
        self.socket.onerror = ws_onError;
        self.socket.onclose = transitionToWaiting;

        // allow time to get connected-to-Pusher message, otherwise close socket, try again
        self._openTimer = setTimeout(TransitionToImpermanentClosing, self.connectedTimeout);
      },

      openExit: function() {
        clearTimeout(self._openTimer);
      },

      openToWaiting: function() {
        updateConnectionParameters();
      },

      openToImpermanentlyClosing: function() {
        updateConnectionParameters();
      },

      connectedPre: function(socket_id) {
        self.socket_id = socket_id;

        self.socket.onmessage = ws_onMessage;
        self.socket.onerror = ws_onError;
        self.socket.onclose = function() {
          self._machine.transition('waiting');
        };
        // onoffline called by some browsers on loss of connection to router
        self.netInfo.bind('offline', function() {
          if(self._machine.is('connected'))
            self.socket.close();
        });

        resetConnectionParameters(self);
      },

      connectedPost: function() {
        triggerStateChange('connected');
      },

      connectedExit: function() {
        triggerStateChange('disconnected');
      },

      impermanentlyClosingPost: function() {
        self.socket.onclose = transitionToWaiting;
        self.socket.close();
      },

      permanentlyClosingPost: function() {
        self.socket.onclose = function() {
          resetConnectionParameters(self);
          self._machine.transition('permanentlyClosed');
        };

        self.socket.close();
      },

      failedPre: function() {
        triggerStateChange('failed');
        Pusher.debug('WebSockets are not available in this browser.');
      }
    });

    /*-----------------------------------------------
      -----------------------------------------------*/

    function updateConnectionParameters() {
      if (self.connectionWait < MAX_CONNECTION_ATTEMPT_WAIT) {
        self.connectionWait += UNSUCCESSFUL_CONNECTION_ATTEMPT_ADDITIONAL_WAIT;
      }

      if (self.openTimeout < MAX_OPEN_ATTEMPT_TIMEOUT) {
        self.openTimeout += UNSUCCESSFUL_OPEN_ATTEMPT_ADDITIONAL_TIMEOUT;
      }

      if (self.connectedTimeout < MAX_CONNECTED_ATTEMPT_TIMEOUT) {
        self.connectedTimeout += UNSUCCESSFUL_CONNECTED_ATTEMPT_ADDITIONAL_TIMEOUT;
      }

      if (self.compulsorySecure !== true) {
        self.connectionSecure = !self.connectionSecure;
      }

      self.connectionAttempts++;
    }

    function formatURL(key, isSecure) {
      var port = Pusher.ws_port;
      var protocol = 'ws://';

      if (isSecure) {
        port = Pusher.wss_port;
        protocol = 'wss://';
      }

      return protocol + Pusher.host + ':' + port + '/app/' + key + '?client=js&version=' + Pusher.VERSION;
    }

    // callback for close and retry.  Used on timeouts.
    function TransitionToImpermanentClosing() {
      self._machine.transition('impermanentlyClosing');
    }

    /*-----------------------------------------------
      WebSocket Callbacks
      -----------------------------------------------*/

    // no-op, as we only care when we get pusher:connection_established
    function ws_onopen() {
      self._machine.transition('open');
    };

    function ws_onMessage(event) {
      var params = parseWebSocketEvent(event);

      // case of invalid JSON payload sent
      // we have to handle the error in the parseWebSocketEvent
      // method as JavaScript error objects are kinda icky.
      if (typeof params === 'undefined') return;

      Pusher.debug('Event recd (event,data)', params.event, params.data);

      // Continue to work with valid payloads:
      if (params.event === 'pusher:connection_established') {
        self._machine.transition('connected', params.data.socket_id);
      } else if (params.event === 'pusher:error') {
        // first inform the end-developer of this error
        informUser('error', {type: 'PusherError', data: params.data});

        // App not found by key - close connection
        if (params.data.code === 4001) {
          self._machine.transition('permanentlyClosing');
        }
      } else if (params.event === 'pusher:heartbeat') {
      } else if (self._machine.is('connected')) {
        informUser('message', params);
      }
    }


    /**
     * Parses an event from the WebSocket to get
     * the JSON payload that we require
     *
     * @param {MessageEvent} event  The event from the WebSocket.onmessage handler.
    **/
    function parseWebSocketEvent(event) {
      try {
        var params = JSON.parse(event.data);

        if (typeof params.data === 'string') {
          try {
            params.data = JSON.parse(params.data);
          } catch (e) {
            if (!(e instanceof SyntaxError)) {
              throw e;
            }
          }
        }

        return params;
      } catch (e) {
        informUser('error', {type: 'MessageParseError', error: e, data: event.data});
      }
    }

    function transitionToWaiting() {
      self._machine.transition('waiting');
    }

    function ws_onError() {
      informUser('error', {
        type: 'WebSocketError'
      });

      // note: required? is the socket auto closed in the case of error?
      self.socket.close();
      self._machine.transition('impermanentlyClosing');
    }

    function informUser(eventName, data) {
      self.emit(eventName, data);
    }

    function triggerStateChange(newState, data) {
      // avoid emitting and changing the state
      // multiple times when it's the same.
      if (self.state === newState) return;

      var prevState = self.state;

      self.state = newState;

      Pusher.debug('State changed', prevState + ' -> ' + newState);

      self.emit('state_change', {previous: prevState, current: newState});
      self.emit(newState, data);
    }

    // Offline means definitely offline (no connection to router).
    // Inverse does NOT mean definitely online (only currently supported in Safari
    // and even there only means the device has a connection to the router).
    function netInfoSaysOffline() {
      return self.netInfo.isOnLine() === false;
    }
  };

  Connection.prototype.connect = function() {
    // no WebSockets
    if (Pusher.Transport === null) {
      this._machine.transition('failed');
    }
    // initial open of connection
    else if(this._machine.is('initialized')) {
      resetConnectionParameters(this);
      this._machine.transition('waiting');
    }
    // user skipping connection wait
    else if (this._machine.is('waiting')) {
      this._machine.transition('connecting');
    }
    // user re-opening connection after closing it
    else if(this._machine.is("permanentlyClosed")) {
      this._machine.transition('waiting');
    }
  };

  Connection.prototype.send = function(data) {
    if (this._machine.is('connected')) {
      this.socket.send(data);
      return true;
    } else {
      return false;
    }
  };

  Connection.prototype.disconnect = function() {
    if (this._machine.is('waiting')) {
      this._machine.transition('permanentlyClosed');
    } else {
      this._machine.transition('permanentlyClosing');
    }
  };

  Pusher.Util.extend(Connection.prototype, Pusher.EventsDispatcher.prototype);
  this.Pusher.Connection = Connection;

  /*
    A little bauble to interface with window.navigator.onLine,
    window.ononline and window.onoffline.  Easier to mock.
  */
  var NetInfo = function() {
    var self = this;
    window.ononline = function() {
      self.emit('online', null);
    };
    window.onoffline = function() {
      self.emit('offline', null);
    };
  };

  NetInfo.prototype.isOnLine = function() {
    return window.navigator.onLine;
  };

  Pusher.Util.extend(NetInfo.prototype, Pusher.EventsDispatcher.prototype);
  this.Pusher.Connection.NetInfo = NetInfo;

}).call(this);

Pusher.Channels = function() {
  this.channels = {};
};

Pusher.Channels.prototype = {
  add: function(channel_name, pusher) {
    var existing_channel = this.find(channel_name);
    if (!existing_channel) {
      var channel = Pusher.Channel.factory(channel_name, pusher);
      this.channels[channel_name] = channel;
      return channel;
    } else {
      return existing_channel;
    }
  },

  find: function(channel_name) {
    return this.channels[channel_name];
  },

  remove: function(channel_name) {
    delete this.channels[channel_name];
  },

  disconnect: function () {
    for(var channel_name in this.channels){
      this.channels[channel_name].disconnect()
    }
  }
};

Pusher.Channel = function(channel_name, pusher) {
  Pusher.EventsDispatcher.call(this);

  this.pusher = pusher;
  this.name = channel_name;
  this.subscribed = false;
};

Pusher.Channel.prototype = {
  // inheritable constructor
  init: function(){

  },

  disconnect: function(){

  },

  // Activate after successful subscription. Called on top-level pusher:subscription_succeeded
  acknowledge_subscription: function(data){
    this.subscribed = true;
  },

  is_private: function(){
    return false;
  },

  is_presence: function(){
    return false;
  },

  authorize: function(pusher, callback){
    callback(false, {}); // normal channels don't require auth
  },

  trigger: function(event, data) {
    this.pusher.send_event(event, data, this.name);
    return this;
  }
};

Pusher.Util.extend(Pusher.Channel.prototype, Pusher.EventsDispatcher.prototype);



Pusher.auth_callbacks = {};

Pusher.authorizers = {
  ajax: function(pusher, callback){
    var self = this;
    var xhr = window.XMLHttpRequest ?
      new XMLHttpRequest() :
      new ActiveXObject("Microsoft.XMLHTTP");
    xhr.open("POST", Pusher.channel_auth_endpoint, true);
    xhr.setRequestHeader("Content-Type", "application/x-www-form-urlencoded")
    xhr.onreadystatechange = function() {
      if (xhr.readyState == 4) {
        if (xhr.status == 200) {
          var data = JSON.parse(xhr.responseText);
          callback(false, data);
        } else {
          Pusher.debug("Couldn't get auth info from your webapp", status);
          callback(true, xhr.status);
        }
      }
    };
    xhr.send('socket_id=' + encodeURIComponent(pusher.connection.socket_id) + '&channel_name=' + encodeURIComponent(self.name));
  },
  jsonp: function(pusher, callback){
    var qstring = 'socket_id=' + encodeURIComponent(pusher.connection.socket_id) + '&channel_name=' + encodeURIComponent(this.name);
    var script = document.createElement("script");
    // Hacked wrapper.
    Pusher.auth_callbacks[this.name] = function(data) {
      callback(false, data);
    };
    var callback_name = "Pusher.auth_callbacks['" + this.name + "']";
    script.src = Pusher.channel_auth_endpoint+'?callback='+encodeURIComponent(callback_name)+'&'+qstring;
    var head = document.getElementsByTagName("head")[0] || document.documentElement;
    head.insertBefore( script, head.firstChild );
  }
};

Pusher.Channel.PrivateChannel = {
  is_private: function(){
    return true;
  },

  authorize: function(pusher, callback){
    Pusher.authorizers[Pusher.channel_auth_transport].scopedTo(this)(pusher, callback);
  }
};

Pusher.Channel.PresenceChannel = {

  init: function(){
    this.bind('pusher_internal:subscription_succeeded', function(sub_data){
      this.acknowledge_subscription(sub_data);
      this.dispatch_with_all('pusher:subscription_succeeded', this.members);
    }.scopedTo(this));

    this.bind('pusher_internal:member_added', function(data){
      var timeoutMember = this.members.get(data.user_id);

      if(timeoutMember && timeoutMember.info.timeoutID){ // The member is present with a timeout
        clearTimeout(timeoutMember.info.timeoutID);
      }else{
        var member = this.members.add(data.user_id, data.user_info);
        this.dispatch_with_all('pusher:member_added', member);
      }
    }.scopedTo(this))

    this.bind('pusher_internal:member_removed', function(data){
      var that = this;
      var member = this.members.remove(data.user_id); // temporally removing

      member.info.timeoutID = setTimeout(function(){
          var member = that.members.remove(data.user_id);
          if (member) {
            that.dispatch_with_all('pusher:member_removed', member);
          }
        }, Pusher.presence_timeout);

      // Adding again with the timeout attribute
      this.members.add(member.id, member.info);
    }.scopedTo(this))
  },

  disconnect: function(){
    this.members.clear();
  },

  acknowledge_subscription: function(sub_data){
    this.members._members_map = sub_data.presence.hash;
    this.members.count = sub_data.presence.count;
    this.subscribed = true;
  },

  is_presence: function(){
    return true;
  },

  members: {
    _members_map: {},
    count: 0,

    each: function(callback) {
      for(var i in this._members_map) {
        callback({
          id: i,
          info: this._members_map[i]
        });
      }
    },

    add: function(id, info) {
      this._members_map[id] = info;
      this.count++;
      return this.get(id);
    },

    remove: function(user_id) {
      var member = this.get(user_id);
      if (member) {
        delete this._members_map[user_id];
        this.count--;
      }
      return member;
    },

    get: function(user_id) {
      if (this._members_map.hasOwnProperty(user_id)) { // have heard of this user user_id
        return {
          id: user_id,
          info: this._members_map[user_id]
        }
      } else { // have never heard of this user
        return null;
      }
    },

    clear: function() {
      this._members_map = {};
      this.count = 0;
    }
  }
};

Pusher.Channel.factory = function(channel_name, pusher){
  var channel = new Pusher.Channel(channel_name, pusher);
  if(channel_name.indexOf(Pusher.Channel.private_prefix) === 0) {
    Pusher.Util.extend(channel, Pusher.Channel.PrivateChannel);
  } else if(channel_name.indexOf(Pusher.Channel.presence_prefix) === 0) {
    Pusher.Util.extend(channel, Pusher.Channel.PrivateChannel);
    Pusher.Util.extend(channel, Pusher.Channel.PresenceChannel);
  };
  channel.init();// inheritable constructor
  return channel;
};

Pusher.Channel.private_prefix = "private-";
Pusher.Channel.presence_prefix = "presence-";

var _require = (function () {

  var handleScriptLoaded;
  if (document.addEventListener) {
    handleScriptLoaded = function (elem, callback) {
      elem.addEventListener('load', callback, false)
    }
  } else {
    handleScriptLoaded = function(elem, callback) {
      elem.attachEvent('onreadystatechange', function () {
        if(elem.readyState == 'loaded' || elem.readyState == 'complete') callback()
      })
    }
  }

  return function (deps, callback) {
    var dep_count = 0,
    dep_length = deps.length;

    function checkReady (callback) {
      dep_count++;
      if ( dep_length == dep_count ) {
        // Opera needs the timeout for page initialization weirdness
        setTimeout(callback, 0);
      }
    }

    function addScript (src, callback) {
      callback = callback || function(){}
      var head = document.getElementsByTagName('head')[0];
      var script = document.createElement('script');
      script.setAttribute('src', src);
      script.setAttribute("type","text/javascript");
      script.setAttribute('async', true);

      handleScriptLoaded(script, function () {
        checkReady(callback);
      });

      head.appendChild(script);
    }

    for(var i = 0; i < dep_length; i++) {
      addScript(deps[i], callback);
    }
  }
})();

;(function() {
  var cdn = (document.location.protocol == 'http:') ? Pusher.cdn_http : Pusher.cdn_https;
  var root = cdn + Pusher.VERSION;

  var deps = [];
  if (typeof window['JSON'] === 'undefined') {
    deps.push(root + '/json2.js');
  }
  if (typeof window['WebSocket'] === 'undefined') {
    // We manually initialize web-socket-js to iron out cross browser issues
    window.WEB_SOCKET_DISABLE_AUTO_INITIALIZATION = true;
    deps.push(root + '/flashfallback.js');
  }

  var initialize = function() {
    Pusher.NetInfo = Pusher.Connection.NetInfo;

    if (typeof window['WebSocket'] === 'undefined' && typeof window['MozWebSocket'] === 'undefined') {
      return function() {
        // This runs after flashfallback.js has loaded
        if (typeof window['WebSocket'] !== 'undefined') {
          // window['WebSocket'] is a flash emulation of WebSocket
          Pusher.Transport = window['WebSocket'];
          Pusher.TransportType = 'flash';

          window.WEB_SOCKET_SWF_LOCATION = root + "/WebSocketMain.swf";
          WebSocket.__addTask(function() {
            Pusher.ready();
          })
          WebSocket.__initialize();
        } else {
          // Flash must not be installed
          Pusher.Transport = null;
          Pusher.TransportType = 'none';
          Pusher.ready();
        }
      }
    } else {
      return function() {
        // This is because Mozilla have decided to
        // prefix the WebSocket constructor with "Moz".
        if (typeof window['MozWebSocket'] !== 'undefined') {
          Pusher.Transport = window['MozWebSocket'];
        } else {
          Pusher.Transport = window['WebSocket'];
        }
        // We have some form of a native websocket,
        // even if the constructor is prefixed:
        Pusher.TransportType = 'native';

        // Initialise Pusher.
        Pusher.ready();
      }
    }
  }();

  var ondocumentbody = function(callback) {
    var load_body = function() {
      document.body ? callback() : setTimeout(load_body, 0);
    }
    load_body();
  };

  var initializeOnDocumentBody = function() {
    ondocumentbody(initialize);
  }

  if (deps.length > 0) {
    _require(deps, initializeOnDocumentBody);
  } else {
    initializeOnDocumentBody();
  }
})();

