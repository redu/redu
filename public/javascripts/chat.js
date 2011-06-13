/*
 var mychat = buildChat({
     key : 'XXX',
     channel : '123',
     timeout : '123',
     endPoint : 'httto' });
 */

// Utilizando pjax
$("a:not([data-remote])").pjax("#content", { timeout: null });

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

  $.storeWindow = function(opts) {
    var memberInfos = {
      "id" : opts.id,
      "name" : opts.name,
      "status" : "online",
      "state" : "opened"
    };
    var storedWindows = $.evalJSON($.cookie("chatWindows"));
    var alreadyExists = false;

    for(i in storedWindows) {
      if (storedWindows[i].id == opts.id) { alreadyExists = true; }
    }

    if (!alreadyExists) {
      if (storedWindows) {
        storedWindows.push(memberInfos);
      } else {
        storedWindows = [memberInfos];
      }
      var windowsEncoded = $.toJSON(storedWindows);
      $.cookie("chatWindows", windowsEncoded);
    }
  };

  $.removeWindow = function(opts) {
    var cookie = $.evalJSON($.cookie("chatWindows"));
    var itemToRemove;
    for(i in cookie) {
      if (cookie[i].id == opts.id) { itemToRemove = i; }
    }
    cookie.splice(itemToRemove, 1);

    if (cookie && cookie.length == 0) {
      $.cookie("chatWindows", null);
    } else {
      var windowsEncoded = $.toJSON(cookie);
      $.cookie("chatWindows", windowsEncoded);
    }
  };

  $.changeWindow = function(opts) {
    var cookie = $.evalJSON($.cookie("chatWindows"));
    for(i in cookie) {
      if (cookie[i].id == opts.id) { cookie[i][opts.property] = opts.value; }
    }
    var windowsEncoded = $.toJSON(cookie);
    $.cookie("chatWindows", windowsEncoded);
  }

  $.restoreWindows = function(container) {
    var cookie = $.evalJSON($.cookie("chatWindows"));
    for(i in cookie) {
      var win = cookie[i];
      container.addWindow({ template : $window.clone(),
          id : win.id,
          name : win.name,
          "status" : win["status"],
          state : win.state });
    }
  }

  $.fn.addWindow = function(opts){
    return this.each(function(){
        var $this = $(this);
        var $window = $("#" + getCSSWindowId(opts.id));
        if($window.length > 0){
          if($window.find(".chat-window-bar").hasClass("closed")) {
            $window.find(".chat-window-bar .name").click();
            $.changeWindow({ id : opts.id, property : "state", value : "opened" });
          }
        }else{
          var $template = opts.template;
          $template.attr("id", getCSSWindowId(opts.id));
          $template.find(".name").text(opts.name);
          $template.find(".online").addClass(opts["status"]);
          $template.find(".online").text(opts["status"]);
          $template.find(".chat-window-bar").addClass(opts.state);
          if (opts.state == "closed") {
            $template.find(".chat-window").hide();
          }

          // minimizar e maximizar
          $template.find(".name").bind("click", function(e){
              var $bar = $template.find(".chat-window-bar");
              $template.find(".chat-window").toggle();
              $bar.toggleClass("opened");
              $bar.toggleClass("closed");
              if ($bar.hasClass("opened")) {
                $.changeWindow({ id : opts.id, property : "state",
                    value : "opened" });
              } else {
                $.changeWindow({ id : opts.id, property : "state",
                    value : "closed" });
              }
              e.preventDefault();
          });
          // fechar janela de chat
          $template.find(".close").bind("click", function(e){
              $template.remove();
              // Remove estado da janela do cookie
              $.removeWindow({ id: opts.id });
              e.preventDefault();
          });

          $this.append($template);

          // Guarda estado da janela no cookie
          $.storeWindow({ id: opts.id, name : opts.name });
        }

    });
  };

  // Adiciona um contato à lista de contatos
  $.fn.addContact = function(opts){
    return this.each(function(){
        var $this = $(this);
        var $template = $(opts.template);
        var $role = $template.find(".role");

        $template.attr("id", getCSSUserId(opts.member.id));
        $template.find("img").attr("src", opts.member.info.thumbnail);
        $template.find(".name").text(opts.member.info.name);

        // Adicionando papel do usuário (o mais relevante será mostrado)
        if(opts.member.info.roles["member"]){ $role.text("Aluno"); }
        if(opts.member.info.roles["tutor"]){ $role.text("Tutor"); }
        if(opts.member.info.roles["teacher"]){ $role.text("Professor"); }
        if(opts.member.info.roles["environment_admin"]){ $role.text("Administrador"); }
        if(opts.member.info.roles["admin"]){ $role.text("Staff"); }

        $this.bind("click", function(){
            $layout.find("#chat-windows-list").addWindow({ template : $window.clone()
                , id : opts.member.id
                , name : opts.member.info.name
                , "status" : "online"
                , state : "opened" });
        });

        $this.append($template);
    });
  };

  // Remove contato da lista de contatos e mostra indicativo de offline na janela
  $.fn.removeContact = function(opts){
    var $statusDiv = $("#" + getCSSWindowId(opts.id) + " .chat-window-bar .online");
    var $removed = $("#" + getCSSUserId(opts.id)).remove();

    $statusDiv.removeClass("online").addClass("offline");
    $statusDiv.text("off-line");
    $(this).updateCounter();

    return $removed;
  }

  // Atualiza contador de usuários online
  $.fn.updateCounter = function(){
    var count = $(this).find("#chat-contacts li").length;
    $(this).find("#chat-contacts-bar .count").text("Chat ("+ count +")");

    return $(this);
  };

  // Adiciona scroll
  $.fn.scrollable = function(config){
    var options = { offset : 10 };
    options = $.extend(options, config);

    return this.each(function(){
        var $this = $(this);

        $list = $this.find("ul");
        $list.css("overflow", "hidden");

        $this.find(".scroll .down").live("click", function(){
            $list.scrollTop($list.scrollTop() + options.offset);
        });

        $this.find(".scroll .up").live("click", function(){
            $list.scrollTop($list.scrollTop() - options.offset);
        });

    });
  };

  // Minimiza lista de contatos
  $layout.find("#chat-contacts .minimize, #chat-contacts-bar").bind("click", function(){
      $layout.find("#chat-contacts").toggle();
      $layout.find("#chat-contacts-bar").toggleClass("opened").toggleClass("closed");
  });

  var that = {
    // Inicializa o pusher e mostra a barra de chat
    init : function(){
      // Initicializando layout
      $("body").append($layout);
      $layout.find("#chat-contacts").scrollable();
      // Restaura o estado das janelas
      $.restoreWindows($layout.find("#chat-windows-list"));
      Pusher.presence_timeout = config.presence_timeout;
      Pusher.channel_auth_endpoint = config.endPoint;
      // Informações de log
      if(config.log){
        Pusher.log = function(message) {
          if (console && console.log) console.log(arguments);
        };
      }
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
      $layout.find("#chat-contacts ul").addContact({member : member, template : $presence });
      that.uiUpdateCounter();
    },
    // Remove da lista de contatos
    uiRemoveContact : function(userId){
      $layout.removeContact({ id : userId });
      // Muda status da janela no cookie
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
