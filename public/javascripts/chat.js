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

  var $layout;
  if(config.layout instanceof jQuery)
    $layout = config.layout;
  else
    $layout = $(config.layout);

  var $window;
  if(config.window instanceof jQuery)
    $window = config.windowPartial;
  else
    $window = $(config.windowPartial);

  var $presence;
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

  $.fn.addWindow = function(opts){
    return this.each(function(){
        var $this = $(this);

        var $window = $("#" + getCSSWindowId(opts.id));
        if($window.length > 0){
          if($window.find(".chat-window-bar").hasClass("closed"))
            $window.find(".chat-window-bar .name").click();
        }else{
          var $template = opts.template;
          $template.attr("id", getCSSWindowId(opts.id));
          $template.find(".name").text(opts.name);

          // minimizar e maximizar
          $template.find(".name").bind("click", function(e){
              var $bar = $template.find(".chat-window-bar");

              $template.find(".chat-window").toggle();
              $bar.toggleClass("opened");
              $bar.toggleClass("closed");

              e.preventDefault();
          });

          // fechar janela de chat
          $template.find(".close").bind("click", function(e){
              $template.remove();
              e.preventDefault();
          });

          $this.append($template);
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
                , name : opts.member.info.name });
        });

        $this.append($template);
    });
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
      $("#" + getCSSUserId(userId)).remove();
      var statusDiv = $("#" + getCSSWindowId(getCSSUserId(userId)) + " .chat-window-bar .online");
      statusDiv.removeClass("online").addClass("offline");
      statusDiv.text("off-line");
      that.uiUpdateCounter();
    },
    // Atualiza counter de usuários online
    uiUpdateCounter : function(){
      var count = $layout.find("#chat-contacts li").length;
      $layout.find("#chat-contacts-bar .count").text("Chat ("+ count +")");
    }
  };

  return that;
}

