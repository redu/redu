/*
 var mychat = buildChat({
     key : 'XXX',
     channel : '123',
     timeout : '123',
     endPoint : 'httto' });
 */

// Utilizando pjax
// Links do chat serão abertos em novas janelas (.chat-link)
$("a:not([data-remote]):not(.chat-link)").pjax("#content", { timeout: null });

// Constrói um novo objeto Chat
var buildChat = function(opts){
  var pusher;
  var config = { "endPoint" : '/presence/auth'
    , "log" : false
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

  var getCSSUserId = function(userId) {
    return "chat-user-" + userId;
  };
  var getCSSWindowId = function(userLiId) {
    return "window-" + userLiId;
  };

  // Minimiza lista de contatos
  $layout.find("#chat-contacts .minimize, #chat-contacts-bar").bind("click", function(){
      $layout.find("#chat-contacts").toggle();
      $layout.find("#chat-contacts-bar").toggleClass("opened").toggleClass("closed");
      if ($layout.find("#chat-contacts-bar").hasClass("opened")) {
        $.changeChatList({ opened : true });
      } else {
        $.changeChatList({ opened : false });
      }
  });

  var that = {
    // Inicializa o pusher e mostra a barra de chat
    init : function(){
      // Configurações do pusher
      Pusher.presence_timeout = config.presence_timeout;
      Pusher.channel_auth_endpoint = config.endPoint;

      // Informações de log
      if(config.log){
        Pusher.log = function(message) {
          if (console && console.log) console.log(arguments);
        };
      }

      // Initicializando layout
      $("body").append($layout);
      $layout.find("#chat-contacts").scrollable();

      $.initChatCookies();
      $layout.restoreChat({
          presencePartial : $presence.clone(),
          windowPartial : $window.clone()
      });

      pusher = new Pusher(config.key);
    },
    // Inscreve no canal do usuário logado
    subscribeMyChannel : function(){
      myPresenceCh = pusher.subscribe(config.channel);

      // Escuta evento de confirmação de inscrição no canal
      myPresenceCh.bind("pusher:subscription_succeeded", function(members){
          members.each(function(member) {
              var channels = member.info.friends;
              // Somente o user atual tem info.friends
              if(channels){
                for(var i = 0; i < channels.length; i++) {
                  pusher.subscribe(channels[i].channel);
                }
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
          pusher.subscribe(member.info.channel);
      });

      // Escuta evento de remoção de membro no canal
      myPresenceCh.bind("pusher:member_removed", function(member){
          that.uiRemoveContact(member.id);
          pusher.unsubscribe(member.info.channel);
      });
    },
    // Increve no canal dado (Caso de já estar no chat e aceitar convite de contato)
    subscribeNewContact : function(channel){
      pusher.subscribe(channel);
    },
    // Desinscreve do canal dado
    unsubscribeContact : function(channel){
      pusher.unsubscribe(channel);
    },
    // Adiciona a lista de contatos
    uiAddContact : function(member){
      $layout.addContact({member : member
          , presencePartial : $presence.clone()
          , windowPartial : $window.clone() });
      $.changeWindow({ id : member.id, property : "status",
          value : "online" });
      that.uiUpdateCounter();
    },
    // Remove da lista de contatos
    uiRemoveContact : function(userId){
      $layout.removeContact({ id : userId });
      $.changeWindow({ id : userId, property : "status",
          value : "offline" });
    },
    // Atualiza counter de usuários online
    uiUpdateCounter : function(){
      $layout.updateCounter();
    }
  };

  return that;
}
