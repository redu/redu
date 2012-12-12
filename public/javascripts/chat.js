// Utilizando pjax
var $pjaxLinks = $("a:not([data-remote]):not([href^='#']):not([rel='nofollow']):not([href^='javascript\:']):not([onClick])");;
// Desabilitado enquanto existem dois layouts
//$pjaxLinks.pjax("#pjax-container", { timeout: null });

var buildChat = (function(){
// Constrói um novo objeto Chat
var buildChat = function(opts){
  var pusher;
  var config = { "endPoint" : '/presence/auth'
    , "log" : false
    , "multiAuthEndPoint" : '/presence/multiauth'
    , "presence_timeout" : 20000 };
  config = $.extend(config, opts);

  // Inicializando variaveis de template
  var $layout, $window, $presence;
  if(config.layout instanceof jQuery)
    $layout = config.layout;
  else
    $layout = $(config.layout);

  if(config.window instanceof jQuery)
    $window = config.windowPartial;
  else
    $window = $(config.windowPartial);

  if(config.presencePartial instanceof jQuery)
    $presence = config.presencePartial;
  else
    $presence = $(config.presencePartial);

  if(config.messagePartial instanceof jQuery)
    $message = config.messagePartial;
  else
    $message = $(config.messagePartial);

  var getCSSUserId = function(userId) {
    return "chat-user-" + userId;
  };
  var getCSSWindowId = function(userLiId) {
    return "window-" + userLiId;
  };

  var startsWith = function(check, startsWith){
    return (check.indexOf(startsWith) === 0);
  }

  // Minimiza lista de contatos
  $layout.find("#chat-contacts .minimize, #chat-contacts-bar").bind("click", function(){
      $layout.find("#chat-contacts").toggle();
      $layout.find("#chat-contacts-bar").toggleClass("opened").toggleClass("closed");
      if ($layout.find("#chat-contacts-bar").hasClass("opened")) {
        $.updateContactsState({ opened : true });
      } else {
        $.updateContactsState({ opened : false });
      }
  });

  var that = {
    // Inicializa o pusher e mostra a barra de chat
    init : function(){
      // Configurações do pusher
      Pusher.presence_timeout = config.presence_timeout;
      Pusher.channel_auth_endpoint = config.endPoint;
      Pusher.channel_multiauth_endpoint = config.multiAuthEndPoint;

      // Informações de log
      if(config.log){
        Pusher.log = function(message) {
          if (console && console.log) console.log(arguments);
        };
      }

      // Initicializando layout
      $("body").append($layout);
      $layout = $("#chat");

      $layout.find("#chat-contacts").scrollable();

      $.initStates();
      $layout.restoreStates({
          windowPartial : $window.clone(),
          messagePartial : $message.clone(),
          owner_id : config.owner_id,
      });

      pusher = new Pusher(config.key);
    },
    // Inscreve no canal do usuário logado
    subscribeMyChannel : function(){
      myPresenceCh = pusher.subscribe(config.channel);

      // Escuta evento de confirmação de inscrição no canal
      myPresenceCh.bind("pusher:subscription_succeeded", function(members){
          members.each(function(member) {
              // var channels = member.info.contacts;
              var channels = member.info.contacts;
              // Somente o user atual tem info.contacts
              if(channels){
                that.multiSubscribe(channels);
              } else {
                // Para o restante dos membros do canal
                // (caso em que os contatos entram antes do dono, logo eles
                // devem ser adicionados a interface).
                that.uiAddContact(member);
              }
          });
      });

      // Escuta evento de adição de membro no canal
      myPresenceCh.bind("pusher:member_added", function(member){
          that.uiAddContact(member);
          pusher.subscribe(member.info.pre_channel);

          if (!pusher.channels.find(member.info.pri_channel)) {
            that.subscribePrivate(member.info.pri_channel);
          }
      });

      // Escuta evento de remoção de membro no canal
      myPresenceCh.bind("pusher:member_removed", function(member){
          that.uiRemoveContact(member.id);
          pusher.unsubscribe(member.info.pre_channel);
      });
    },
    // Increve no canal dado (Caso de já estar no chat e aceitar convite de contato)
    subscribePresence : function(channel){
      pusher.subscribe(channel);
    },
    // Desinscreve do canal dado
    unsubscribePresence : function(channel){
      pusher.unsubscribe(channel);
    },
    // Se inscreve no canal privado de um usuário
    subscribePrivate: function(channel){
      var channel = pusher.subscribe(channel);
      that.bindMessage(channel);
    },
    // Escuta evento de mensagem enviada no canal privado
    bindMessage : function(channel) {
      channel.bind("message_sent", function(message){
          if (message.user_id != config.owner_id ){
            $layout.addWindow({
                windowPartial : $window.clone(),
                messagePartial : $message.clone(),
                id : message.user_id,
                owner_id : config.owner_id,
                name : message.name,
                "status" : "online",
                state : "closed"
            });

            $layout.find("#" + getCSSWindowId(message.user_id)).addMessage({
                messagePartial : $message.clone(),
                thumbnail : message.thumbnail,
                text : message.text,
                time : message.time,
                name : message.name,
                id : message.user_id,
                owner_id : config.owner_id
            }).nodge();
        }
      });
    },
    // Desinscreve no canal privado
    unsubscribePrivate : function(channel){
      pusher.unsubscribe(channel);
    },
    multiSubscribe : function(channels){
      var channels = pusher.multiSubscribe(channels);
      for(var prop in channels) {
        if(channels.hasOwnProperty(prop)) {
          that.bindMessage(channels[prop]);
        }
      }
    },
    // Adiciona a lista de contatos
    uiAddContact : function(member){
      $layout.addContact({member : member
          , presencePartial : $presence.clone()
          , windowPartial : $window.clone()
          , messagePartial : $message.clone()
          , owner_id : config.owner_id
      });
      $.updateWindowState({ id : member.id, property : "status",
          value : "online" });
      that.uiUpdateCounter();
    },
    // Remove da lista de contatos
    uiRemoveContact : function(userId){
      $layout.removeContact({ id : userId });
      $.updateWindowState({ id : userId, property : "status",
          value : "offline" });
    },
    // Atualiza counter de usuários online
    uiUpdateCounter : function(){
      $layout.updateCounter();
    }
  };

  return that;
}

  return buildChat;
})();
