describe('Chat', function () {
    afterEach(function () {
        // Limpando elementos adicionados ao DOM
        $("#chat-list").remove();
        $("#chat-bar").remove();
        $("#chat-windows-list").remove();
    });


    it('defines buildChat', function () {
        expect(buildChat).toBeDefined();
    });

    describe('initialization', function () {
        var chat, opts;

        beforeEach(function () {
            // Alias
            this.Ch = Pusher.Channel.prototype;
            this.opts = { key : 'XXX'
              , channel : 'my-channel'
              , layout : ""
              , windowPartial : ""
              , presencePartial : ""};
            this.chat = buildChat(this.opts);

            // Mock do bind subscription_succeeded retornando lista de amigos
            this.bindMock = function(e, func){
              var callbacks = {
                "pusher:subscription_succeeded" : function(f){
                  var members = {
                    each: function(callback) {
                      callback({
                          id: 1,
                          info: {
                            friends : [{channel : "ch1"}, {channel : "ch2"}]
                          },
                      });
                      callback({
                          id: 1,
                          info: {},
                      });
                    }
                  }

                  f(members);
                },
                "pusher:member_added" : function(){},
                "pusher:member_removed" : function(){},
                "pusher:connection_established" : function(){},
                "pusher:connection_disconnected" : function(){},
                "pusher:error" : function(){},
              }

              callbacks[e](func);
            };

            spyOn(Pusher.prototype, "subscribe").andReturn(new Pusher.Channel());
            spyOn(this.Ch, "bind").andCallFake(this.bindMock);

            this.chat.init();
            this.chat.subscribeMyChannel();
        });

        it('defines init', function () {
            expect(this.chat).toBeDefined();
        });

        it('binds subscription succeeded event', function() {
            expect(this.Ch.bind).toHaveBeenCalledWith("pusher:subscription_succeeded", jasmine.any(Function));
        });

        it('subscribes to it own channel', function() {
            expect(Pusher.prototype.subscribe).toHaveBeenCalledWith("my-channel");
        });

        it('subscribes to friends channels', function() {
          expect(Pusher.prototype.subscribe).toHaveBeenCalledWith("ch1");
          expect(Pusher.prototype.subscribe).toHaveBeenCalledWith("ch2");
        });
    });

    describe('when subscribing', function () {
        var chat;
        beforeEach(function () {
            opts = { key : 'XXX', channel : 'my-channel' };
            chat = buildChat(opts);
            chat.init();
        });

        it('defines subscribeMyChannel', function() {
            expect(chat.subscribeMyChannel).toBeDefined();
        });

        it('defines subscribeNewContact', function() {
            expect(chat.subscribeNewContact).toBeDefined();
        });

        xit('subscribes the chat owner to his own pusher channel', function() {
            spyOn(Pusher, "Channel");
            chat.subscribeMyChannel();
            expect(Pusher.Channel).toHaveBeenCalled();
        });

        xit('calls subscribeNewContact to every friend', function(){
            var spy = spyOn(Pusher, "Channel");
            chat.subscribeMyChannel();
            expect(spy.callCount).toEqual(5);
        });
    });

    describe("storing state", function(){
        var infos;
        beforeEach(function() {
            $.cookie("chat_windows", null);
            $.initChatCookies();

            infos = {
              listOpened : true,
              windows : []
            };
        });

        afterEach(function () {
            $.cookie("chat_windows", null);
        });

        it('defines $.initChatCookies', function() {
            expect($.initChatCookies).toBeDefined();
        });

        it('defines $.changeChatList', function() {
            expect($.changeChatList).toBeDefined();
        });

        it('defines $.storeWindow', function() {
            expect($.storeWindow).toBeDefined();
        });

        it('defines $.removeWindow', function() {
            expect($.removeWindow).toBeDefined();
        });

        it('defines $.changeWindow', function() {
            expect($.changeWindow).toBeDefined();
        });

        it('defines $.fn.restoreChat', function() {
            expect($.fn.restoreChat).toBeDefined();
        });

        it("saves chat list state on empty cookie", function() {
            $.initChatCookies();
            expect($.cookie("chat_windows")).toEqual($.toJSON(infos));
        });

        it("saves chat list state on nonempty cookie", function() {
            var memberInfos = {
              "id" : "chat-user-50",
              "name" : "Username Lastname",
              "status" : "online",
              "state" : "opened"
            };
            $.initChatCookies();
            $.storeWindow({ id : memberInfos.id, name : memberInfos.name });

            $.initChatCookies();
            infos.windows = [memberInfos];
            expect($.cookie("chat_windows")).toEqual($.toJSON(infos));
        });

        it("changes chat list state", function(){
            var memberInfos = {
              "id" : "chat-user-50",
              "name" : "Username Lastname",
              "status" : "online",
              "state" : "opened"
            };
            $.storeWindow({ id : memberInfos.id, name : memberInfos.name });

            $.changeChatList({ opened : false });
            infos.listOpened = false;
            infos.windows = [memberInfos];
            expect($.cookie("chat_windows")).toEqual($.toJSON(infos));
        });

        it("saves information on empty cookie", function(){
            var memberInfos = {
              "id" : "chat-user-50",
              "name" : "Username Lastname",
              "status" : "online",
              "state" : "opened"
            };
            infos.windows = [memberInfos];
            $.storeWindow({ id : memberInfos.id, name : memberInfos.name });
            expect($.cookie("chat_windows")).toEqual($.toJSON(infos));
        });

        it("saves information on nonempty cookie", function(){
            // First window
            var memberInfos = {
              "id" : "chat-user-50",
              "name" : "Username Lastname",
              "status" : "online",
              "state" : "opened"
            };
            $.storeWindow({ id : memberInfos.id, name : memberInfos.name });

            // Second window
            var memberInfos2 = {
              "id" : "chat-user-51",
              "name" : "Username1 Lastname1",
              "status" : "online",
              "state" : "opened"
            };
            $.storeWindow({ id : memberInfos2.id, name : memberInfos2.name });
            infos.windows = [memberInfos, memberInfos2];
            expect($.cookie("chat_windows")).toEqual($.toJSON(infos));
        });

        it("removes specified window on cookie with one window", function(){
            // First window
            var memberInfos = {
              "id" : "chat-user-50",
              "name" : "Username Lastname",
              "status" : "online",
              "state" : "opened"
            };
            $.storeWindow({ id : memberInfos.id, name : memberInfos.name });

            $.removeWindow({ id : memberInfos.id });
            infos.windows = [];
            expect($.cookie("chat_windows")).toEqual($.toJSON(infos));
        });

        it("removes specified window on cookie with more than one window", function(){
            // First window
            var memberInfos = {
              "id" : "chat-user-50",
              "name" : "Username Lastname",
              "status" : "online",
              "state" : "opened"
            };
            $.storeWindow({ id : memberInfos.id, name : memberInfos.name });

            // Second window
            var memberInfos1 = {
              "id" : "chat-user-51",
              "name" : "Username1 Lastname1",
              "status" : "online",
              "state" : "closed"
            };
            $.storeWindow({ id : memberInfos1.id, name : memberInfos1.name });

            // Third window
            var memberInfos2 = {
              "id" : "chat-user-52",
              "name" : "Username2 Lastname2",
              "status" : "online",
              "state" : "opened"
            };
            $.storeWindow({ id : memberInfos2.id, name : memberInfos2.name });

            $.removeWindow({ id : memberInfos1.id });
            infos.windows = [memberInfos, memberInfos2];
            expect($.cookie("chat_windows")).toEqual($.toJSON(infos));
        });

        it("changes the status of a specified user", function(){
            // First window
            var memberInfos = {
              "id" : "chat-user-50",
              "name" : "Username Lastname",
              "status" : "online",
              "state" : "opened"
            };
            $.storeWindow({ id : memberInfos.id, name : memberInfos.name });

            // Second window
            var memberInfos1 = {
              "id" : "chat-user-51",
              "name" : "Username1 Lastname1",
              "status" : "online",
              "state" : "opened"
            };
            $.storeWindow({ id : memberInfos1.id, name : memberInfos1.name });

            $.changeWindow({ id : memberInfos1.id, property : "status",
                value : "offline" });
            memberInfos1["status"] = "offline";
            infos.windows = [memberInfos, memberInfos1];
            expect($.cookie("chat_windows")).toEqual($.toJSON(infos));
        });

        it("changes the state of a window", function(){
            // First window
            var memberInfos = {
              "id" : "chat-user-50",
              "name" : "Username Lastname",
              "status" : "online",
              "state" : "opened"
            };
            $.storeWindow({ id : memberInfos.id, name : memberInfos.name });

            // Second window
            var memberInfos1 = {
              "id" : "chat-user-51",
              "name" : "Username1 Lastname1",
              "status" : "online",
              "state" : "opened"
            };
            $.storeWindow({ id : memberInfos1.id, name : memberInfos1.name });

            $.changeWindow({ id : memberInfos1.id, property : "state",
                value : "closed" });
            memberInfos1["state"] = "closed";
            infos.windows = [memberInfos, memberInfos1];
            expect($.cookie("chat_windows")).toEqual($.toJSON(infos));
        });
    });

    describe("restoring state", function(){
        var infos;
        var memberInfos;
        var memberInfos1;
        beforeEach(function() {
            $.cookie("chat_windows", null);
            $.initChatCookies();

            infos = {
              listOpened : true,
              windows : []
            };

            // First window
            memberInfos = {
              "id" : "chat-user-50",
              "name" : "Username Lastname",
              "status" : "online",
              "state" : "opened"
            };
            $.storeWindow({ id : memberInfos.id, name : memberInfos.name });

            // Second window
            memberInfos1 = {
              "id" : "chat-user-51",
              "name" : "Username1 Lastname1",
              "status" : "online",
              "state" : "closed"
            };
            $.storeWindow({ id : memberInfos1.id, name : memberInfos1.name });
        });

        afterEach(function () {
            $.cookie("chat_windows", null);
        });

        it("after reload", function(){
            expect($("chat-user-50")).toExist();
            expect($("chat-user-51")).toExist();

            expect($(memberInfos.id + " chat-window .name")).toHaveText(memberInfos.name);
            expect($(memberInfos1.id + " chat-window .name")).toHaveText(memberInfos1.name);
            expect($(memberInfos.id + " chat-window-bar ." + memberInfos["status"])).toHaveText(memberInfos["status"]);
            expect($(memberInfos1.id + " chat-window-bar ." + memberInfos1["status"])).toHaveText(memberInfos1["status"]);
            expect($(memberInfos.id + " chat-window-bar")).toHaveClass(memberInfos.state);
            expect($(memberInfos1.id + " chat-window-bar")).toHaveClass(memberInfos1.state);
        });
    });
});
