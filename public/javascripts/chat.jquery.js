(function($){

    var getCSSUserId = function(userId) {
      return "chat-user-" + userId;
    };
    var getCSSWindowId = function(userLiId) {
      return "window-" + userLiId;
    };

    $.fn.addWindow = function(opts){
      return this.each(function(){
          var $this = $(this);
          var $window = $this.find("#" + getCSSWindowId(opts.id));

          if($window.length > 0){
            if($window.find(".chat-window-bar").hasClass("closed")){
              $window.find(".chat-window-bar .name").click();
              $.changeWindow({ id : opts.id, property : "state", value : "opened" });
            }
          }else{
            $window = opts.windowPartial;
            $window.attr("id", getCSSWindowId(opts.id));
            $window.find(".name").text(opts.name);
            $window.find(".online").addClass(opts["status"]);
            $window.find(".online").text(opts["status"]);
            $window.find(".chat-window-bar").addClass(opts.state);
            if (opts.state == "closed") {
              $window.find(".chat-window").hide();
            }

            // minimizar e maximizar
            $window.find(".name").bind("click", function(e){
                var $bar = $window.find(".chat-window-bar");

                $window.find(".chat-window").toggle();
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
            $window.find(".close").bind("click", function(e){
                $window.remove();
                // Remove estado da janela do cookie
                $.removeWindow({ id: opts.id });

                e.preventDefault();
            });

            $this.find("#chat-windows-list").append($window);

            // Guarda estado da janela no cookie
            $.storeWindow({ id: opts.id, name : opts.name });
          }
      });
    };

    // Adiciona um contato à lista de contatos
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

          $presence.bind("click", function(){
              $this.addWindow({ windowPartial : opts.windowPartial.clone()
                  , id : opts.member.id
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

    // Restauras janelas registradas no cookie
    $.fn.restoreChat = function(opts) {
      var $this = $(this);
      var chatInfos = $.evalJSON($.cookie("chat_windows"));
      var cookie = chatInfos.windows;

      for(i in cookie) {
        var win = cookie[i];
        $this.addWindow({ id : win.id,
            presencePartial : opts.presencePartial.clone(),
            windowPartial : opts.windowPartial.clone(),
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
    $.removeWindow = function(opts) {
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
    $.storeWindow = function(opts) {
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
    $.changeWindow = function(opts) {
      var chatInfos = $.evalJSON($.cookie("chat_windows"));
      var cookie = chatInfos.windows;
      for(i in cookie) {
        if (cookie[i].id == opts.id) { cookie[i][opts.property] = opts.value; }
      }

      $.cookie("chat_windows", $.toJSON(chatInfos));
    };

    $.initChatCookies = function() {
      var cookie = $.evalJSON($.cookie("chat_windows"));

      if (!cookie) {
        cookie = { listOpened : false, windows: [] };
      }
      var windowsEncoded = $.toJSON(cookie);
      $.cookie("chat_windows", windowsEncoded);
    };

    $.changeChatList = function(opts) {
      var chatInfos = $.evalJSON($.cookie("chat_windows"));
      chatInfos.listOpened = opts.opened;
      $.cookie("chat_windows", $.toJSON(chatInfos));
    };

})(jQuery);
