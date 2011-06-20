describe('Chat', function () {
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
                      contacts : [
                          {pre_channel : "ch1", pri_channel : "private-1-2"}
                        , {pre_channel : "ch2", pri_channel : "private-1-3"}]
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
          "message_sent" : function(f){
            var data = [
              { user : 1, time : function(){ return Date.now(); }, message : "new message"},
              { user : 1, time : function(){ return Date.now(); }, message : "new message"},
            ]

            f(data);
          }
        }

        callbacks[e](func);
      };

      spyOn(Pusher.prototype, "subscribe").andReturn(new Pusher.Channel());
      spyOn(this.Ch, "bind").andCallFake(this.bindMock);

      this.chat.init();
      this.chat.subscribeMyChannel();
    });


    it('defines buildChat', function () {
        expect(buildChat).toBeDefined();
    });

    describe('initialization', function () {

        it('defines init', function () {
            expect(this.chat).toBeDefined();
        });

        it('binds subscription succeeded event', function() {
            expect(this.Ch.bind).toHaveBeenCalledWith("pusher:subscription_succeeded", jasmine.any(Function));
        });

        it('subscribes to it own channel', function() {
            expect(Pusher.prototype.subscribe).toHaveBeenCalledWith("my-channel");
        });

        it('subscribes to friends presence channels', function() {
          expect(Pusher.prototype.subscribe).toHaveBeenCalledWith("ch1");
          expect(Pusher.prototype.subscribe).toHaveBeenCalledWith("ch2");
        });

        it('subscribes to friends private channels', function(){
          expect(Pusher.prototype.subscribe).toHaveBeenCalledWith("private-1-2")
        });
    });

    describe('when subscribing to private channel', function () {
      it('binds to message_sent event', function () {
        this.chat.subscribePrivate("private-1-3");
        expect(this.Ch.bind).toHaveBeenCalledWith("message_sent", jasmine.any(Function));
      });
    });


    describe("storing state", function(){
        var infos;
        beforeEach(function() {
            $.cookie("chat_windows", null);
            $.initStates();

            infos = {
              listOpened : false,
              windows : []
            };
        });

        afterEach(function () {
            $.cookie("chat_windows", null);
        });

        it('defines $.initStates', function() {
            expect($.initStates).toBeDefined();
        });

        it('defines $.updateContactsState', function() {
            expect($.updateContactsState).toBeDefined();
        });

        it('defines $.storeState', function() {
            expect($.storeState).toBeDefined();
        });

        it('defines $.clearState', function() {
            expect($.clearState).toBeDefined();
        });

        it('defines $.updateWindowState', function() {
            expect($.updateWindowState).toBeDefined();
        });

        it('defines $.fn.restoreStates', function() {
            expect($.fn.restoreStates).toBeDefined();
        });

        it("saves chat list state on empty cookie", function() {
            $.initStates();
            expect($.cookie("chat_windows")).toEqual($.toJSON(infos));
        });

        it("saves chat list state on nonempty cookie", function() {
            var memberInfos = {
              "id" : "chat-user-50",
              "name" : "Username Lastname",
              "status" : "online",
              "state" : "opened"
            };
            $.initStates();
            $.storeState({ id : memberInfos.id, name : memberInfos.name });

            $.initStates();
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
            $.storeState({ id : memberInfos.id, name : memberInfos.name });

            $.updateContactsState({ opened : false });
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
            $.storeState({ id : memberInfos.id, name : memberInfos.name });
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
            $.storeState({ id : memberInfos.id, name : memberInfos.name });

            // Second window
            var memberInfos2 = {
              "id" : "chat-user-51",
              "name" : "Username1 Lastname1",
              "status" : "online",
              "state" : "opened"
            };
            $.storeState({ id : memberInfos2.id, name : memberInfos2.name });
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
            $.storeState({ id : memberInfos.id, name : memberInfos.name });

            $.clearState({ id : memberInfos.id });
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
            $.storeState({ id : memberInfos.id, name : memberInfos.name });

            // Second window
            var memberInfos1 = {
              "id" : "chat-user-51",
              "name" : "Username1 Lastname1",
              "status" : "online",
              "state" : "closed"
            };
            $.storeState({ id : memberInfos1.id, name : memberInfos1.name });

            // Third window
            var memberInfos2 = {
              "id" : "chat-user-52",
              "name" : "Username2 Lastname2",
              "status" : "online",
              "state" : "opened"
            };
            $.storeState({ id : memberInfos2.id, name : memberInfos2.name });

            $.clearState({ id : memberInfos1.id });
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
            $.storeState({ id : memberInfos.id, name : memberInfos.name });

            // Second window
            var memberInfos1 = {
              "id" : "chat-user-51",
              "name" : "Username1 Lastname1",
              "status" : "online",
              "state" : "opened"
            };
            $.storeState({ id : memberInfos1.id, name : memberInfos1.name });

            $.updateWindowState({ id : memberInfos1.id, property : "status",
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
            $.storeState({ id : memberInfos.id, name : memberInfos.name });

            // Second window
            var memberInfos1 = {
              "id" : "chat-user-51",
              "name" : "Username1 Lastname1",
              "status" : "online",
              "state" : "opened"
            };
            $.storeState({ id : memberInfos1.id, name : memberInfos1.name });

            $.updateWindowState({ id : memberInfos1.id, property : "state",
                value : "closed" });
            memberInfos1["state"] = "closed";
            infos.windows = [memberInfos, memberInfos1];
            expect($.cookie("chat_windows")).toEqual($.toJSON(infos));
        });
    });

    describe("wrapping URLs", function(){
        it("defines $.wrapURL", function(){
            expect($.wrapURL).toBeDefined();
        });

        it("wraps URLs on text with URLs", function(){
            var text = "Try http://redu.com.br";
            var textWrapped = "Try <a href='http://redu.com.br' class='chat-link' target='_blank'>http://redu.com.br</a>";
            expect($.wrapURL(text)).toEqual(textWrapped);
        });

        it("do NOT wrap URLs on text without URLs", function(){
            var text = "Try redu.com.br";
            expect($.wrapURL(text)).toEqual(text);
        });
    });
});
