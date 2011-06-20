(function($){

    var getCSSUserId = function(userId) {
      return "chat-user-" + userId;
    };
    var getCSSWindowId = function(userLiId) {
      return "window-" + userLiId;
    };
    var getUserId = function(jQueryElement){
      var windowId = jQueryElement.attr("id");
      return windowId.charAt(windowId.length - 1);
    };

    // Encapsula as URLs contidas no texto em links HTML
    $.wrapURL = function(text) {
      var exp = /(\b(https?|ftp|file):\/\/[-A-Z0-9+&@#\/%?=~_|!:,.;]*[-A-Z0-9+&@#\/%=~_|])/ig;
      return text.replace(exp,"<a href='$1' class='chat-link' target='_blank'>$1</a>");
    };

    // Minimiza todas as janelas, exceto a que invocou a função
    $.fn.minimizeOtherWindows = function(){
      var $this = $(this);
      var $chats = $this.parent("#chat-windows-list");

      var $otherWindows = $chats.find(".chat-window-bar.opened").not("#" + $this.attr("id") + " .chat-window-bar");
      $otherWindows.removeClass("opened").addClass("closed");
      $otherWindows.prev(".chat-window").hide();

      for (i = 0; i < $otherWindows.length; i++) {
        var userId = getUserId($otherWindows.parent());

        $.updateWindowState({ id : userId, property : "state",
            value : "closed" });
      }
    };

    // Remove a última janela, caso atinja o limite máximo de janelas
    $.fn.limitWindows = function(opts){
      $this = $(this);
      $chats = $this.find("#chat-windows-list");

      if ($chats.children().length >= opts.limit) {
        var $lastWindow = $chats.children(":last");
        $lastWindow.remove();

        var userId = getUserId($lastWindow);
        $.clearState({ id: userId });
      }
    };

    $.fn.addWindow = function(opts){
      return this.each(function(){
          var $this = $(this);
          var $window = $this.find("#" + getCSSWindowId(opts.id));

          if($window.length > 0){
            if($window.find(".chat-window-bar").hasClass("closed")){
              $window.find(".chat-window-bar .name").click();
              $.updateWindowState({ id : opts.id, property : "state", value : "opened" });
            }
          }else{
            $this.limitWindows({ limit : 5});

            $window = opts.windowPartial;
            $window.attr("id", getCSSWindowId(opts.id));
            $window.find(".name").text(opts.name);
            $window.find(".online").text(opts["status"]);
            $window.find(".online").removeClass("online").addClass(opts["status"]);
            $window.find(".chat-window-bar").addClass(opts.state);
            if (opts.state == "closed") {
              $window.find(".chat-window").hide();
            }
            $window.find(".user-input .contact-id").val(opts.id);

            // minimizar e maximizar
            $window.find(".name").bind("click", function(e){
                var $bar = $window.find(".chat-window-bar");

                $window.find(".chat-window").toggle();
                $bar.toggleClass("opened");
                $bar.toggleClass("closed");

                $window.minimizeOtherWindows();

                if ($bar.hasClass("opened")) {
                  $.updateWindowState({ id : opts.id, property : "state",
                      value : "opened" });
                } else {
                  $.updateWindowState({ id : opts.id, property : "state",
                      value : "closed" });
                }

                e.preventDefault();
            });

            // fechar janela de chat
            $window.find(".close").bind("click", function(e){
                $window.remove();
                // Remove estado da janela do cookie
                $.clearState({ id: opts.id });

                e.preventDefault();
            });

            // Receber confirmação do envio da mensagem
            var $form = $window.find("form.user-input");
            $form.bind("ajax:beforeSend", function(){
                var $input = $form.find(".message");
                var text = $input.val();
                $input.val("");

                $window.addMessage({
                    messagePartial : opts.messagePartial.clone(),
                    text : text,
                    id : opts.owner_id,
                    owner_id : opts.owner_id,
                });

            });

            $form.bind("ajax:success", function(e, data, s){
                var $conversation = $window.find(".conversation");
                var $lastMessage = $conversation.children(':last');
                $lastMessage.find(".time").html(data.time);
                $lastMessage.find(".messages > li:last").toggleClass("pending");
            });

            $this.find("#chat-windows-list").prepend($window);

            // Guarda estado da janela no cookie
            $.storeState({ id: opts.id, name : opts.name });
          }

          // Apenas minimiza as outras se ela for a janela aberta
          // (no restoreStates() as janelas fechadas também são inseridas e
          // chamar o minimize deixaria todas minimizadas)
          if (opts.state == "opened") {
            $window.minimizeOtherWindows();
          }
      });
    };

    // Adiciona uma mensagem enviada/recebida à janela
    $.fn.addMessage = function(opts){
      return this.each(function(){
          var $this = $(this);
          var $conversation = $this.find(".conversation");
          var $lastBatch = $conversation.find("> :last");
          var $message = opts.messagePartial.clone();
          var sameUser = ($lastBatch.data("user-id") == opts.id);
          var empty = ($lastBatch.length == 0)

          if(!empty && sameUser){ // Nova mensagem é do mesmo dono que a anterior
            $lastBatch.data("user-id", opts.id);
            $lastBatch.find(".messages").append($("<li/>").text(opts.text));
          } else { // Primeira msg ou de um dono diferente que a anterior
            $message.data("user-id", opts.id);
            $message.find(".messages > li").text(opts.text);

            if (opts.id != opts.owner_id) {
              var $thumbnail = $message.find(".avatar");
              $thumbnail.attr("src", opts.thumbnail);
              $thumbnail.attr("alt", opts.name);
              $message.find(".time").html(opts.time);
              $message.removeClass("me").addClass("other");
            }

            $conversation.append($message);
          }

          // Deixa ultima mensagem enviada pelo dono do chat como pendente
          if(opts.owner_id == opts.id){
            $message.addClass("pending")
          }
      });
    };

    // Adiciona um contato à lista de contatos e mostra indicativo de online,
    // caso a janela esteja aberta
    $.fn.addContact = function(opts){
      return this.each(function(){
          var $this = $(this);
          var $contacts = $this.find("#chat-contacts");
          var $presence = $(opts.presencePartial);
          var $role = $presence.find(".role");

          $presence.attr("id", getCSSUserId(opts.member.id));
          $presence.find("img").attr("src", opts.member.info.thumbnail);
          $presence.find(".name").text(opts.member.info.name);

          // Adicionando papel do usuário (o mais relevante será mostrado)
          if(opts.member.info.roles["member"]){ $role.text("Aluno"); }
          if(opts.member.info.roles["tutor"]){ $role.text("Tutor"); }
          if(opts.member.info.roles["teacher"]){ $role.text("Professor"); }
          if(opts.member.info.roles["environment_admin"]){ $role.text("Administrador"); }
          if(opts.member.info.roles["admin"]){ $role.text("Staff"); }

          $contacts.find("ul").append($presence);

          var $statusDiv = $("#" + getCSSWindowId(opts.member.id) + " .chat-window-bar .offline");
          $statusDiv.removeClass("offline").addClass("online");
          $statusDiv.text("online");

          $presence.bind("click", function(){
              $this.addWindow({ windowPartial : opts.windowPartial.clone()
                  , messagePartial : opts.messagePartial.clone()
                  , id : opts.member.id
                  , owner_id : opts.owner_id
                  , name : opts.member.info.name
                  , "status" : "online"
                  , state : "opened" });
          });
      });
    };

    // Remove contato da lista de contatos e mostra indicativo de offline na janela
    $.fn.removeContact = function(opts){
      var $statusDiv = $("#" + getCSSWindowId(opts.id) + " .chat-window-bar .online");
      var $removed = $("#" + getCSSUserId(opts.id)).remove();

      $statusDiv.removeClass("online").addClass("offline");
      $statusDiv.text("offline");
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

    // Restauras janelas registradas no cookie
    $.fn.restoreStates = function(opts) {
      var $this = $(this);
      var chatInfos = $.evalJSON($.cookie("chat_windows"));
      var cookie = chatInfos.windows;

      for(i in cookie) {
        var win = cookie[i];
        $this.addWindow({ windowPartial : opts.windowPartial.clone(),
            messagePartial : opts.messagePartial.clone(),
            id : win.id,
            owner_id : opts.owner_id,
            name : win.name,
            "status" : win["status"],
            state : win.state });
      }

      var chatListOpen = chatInfos.listOpened;
      if (chatListOpen) {
        $this.find("#chat-contacts").toggle();
        $this.find("#chat-contacts-bar").toggleClass("opened").toggleClass("closed");
      }

      return $this;
    };

    // Remove janela do cookie
    $.clearState = function(opts) {
      var chatInfos = $.evalJSON($.cookie("chat_windows"));
      var cookie = chatInfos.windows;
      var itemToRemove;
      for(i in cookie) {
        if (cookie[i].id == opts.id) { itemToRemove = i; }
      }
      cookie.splice(itemToRemove, 1);

      if (cookie && cookie.length == 0) {
        chatInfos.windows = [];
      }

      $.cookie("chat_windows", $.toJSON(chatInfos));
    };

    // Guarda o estado da janela no cookie
    $.storeState = function(opts) {
      var memberInfos = {
        "id" : opts.id,
        "name" : opts.name,
        "status" : "online",
        "state" : "opened" // Estado da janela
      };
      var chatInfos = $.evalJSON($.cookie("chat_windows"));
      var storedWindows = chatInfos.windows;
      var alreadyExists = false;

      for(i in storedWindows) {
        if (storedWindows[i].id == opts.id) { alreadyExists = true; }
      }

      if (!alreadyExists) {
        storedWindows.push(memberInfos);

        $.cookie("chat_windows", $.toJSON(chatInfos));
      }
    };

    // Modificar o state ou status da janela no cookie
    $.updateWindowState = function(opts) {
      var chatInfos = $.evalJSON($.cookie("chat_windows"));
      var cookie = chatInfos.windows;
      for(i in cookie) {
        if (cookie[i].id == opts.id) { cookie[i][opts.property] = opts.value; }
      }

      $.cookie("chat_windows", $.toJSON(chatInfos));
    };

    $.initStates = function() {
      var cookie = $.evalJSON($.cookie("chat_windows"));

      if (!cookie) {
        cookie = { listOpened : false, windows: [] };
      }
      var windowsEncoded = $.toJSON(cookie);
      $.cookie("chat_windows", windowsEncoded);
    };

    $.updateContactsState = function(opts) {
      var chatInfos = $.evalJSON($.cookie("chat_windows"));
      chatInfos.listOpened = opts.opened;
      $.cookie("chat_windows", $.toJSON(chatInfos));
    };

})(jQuery);
