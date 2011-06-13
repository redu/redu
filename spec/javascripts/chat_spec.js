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
            opts = { key : 'XXX', channel : 'my-channel' };
            chat = buildChat(opts);
        });

        it('defines init', function () {
            expect(chat).toBeDefined();
        });

        it('shows a empty list', function() {
            chat.init();

            expect($("#chat-list")).toExist();
        });

    });

    describe('ui methods', function () {
        var chat, member;

        beforeEach(function () {
            chat = buildChat({ key : 'XXX', channel : 'my-channel' });
            chat.init();

            member = {
              "info" : {
                "roles" : {
                  "teacher" : true
                  ,"member" : false
                  ,"administrator" : false
                  ,"tutor" : true
                }
                ,"name" : "Test user"
                ,"thumbnail" : "new/missing_users_thumb_32.png"
              }
              ,"id" : "1234"
            }

            chat.uiAddContact(member);
        });

        it('adds contact to UI', function () {
            expect($("#chat-list ul li").length).toBe(1);
            expect($("#chat-list .name").text()).toBe(member.info.name);
        });

        it('adds the correct role text (more strong role)', function() {
            $("#chat-list .roles .status").remove();
            expect($("#chat-list .roles").filter(":first")).toHaveText("Professor");
        });

        it('creates the user link', function() {
            expect($("#chat-list img").attr("src")).toBe(member.info.thumbnail);
        });

        it('should set data-userId', function() {
            expect($("#chat-user-" + member.id)).toExist();
        });

        it('should remove the user from UI', function() {
            chat.uiRemoveContact(member.id);
            expect($("#chat-user-" + member.id)).not.toExist();
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
        beforeEach(function() {
            $.cookie("chatWindows", null);
        });

        afterEach(function () {
            $.cookie("chatWindows", null);
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

        it('defines $.restoreWindows', function() {
            expect($.restoreWindows).toBeDefined();
        });

        it("saves information on empty cookie", function(){
            var memberInfos = {
              "id" : "chat-user-50",
              "name" : "Username Lastname",
              "status" : "online",
              "state" : "opened"
            };
            $.storeWindow(memberInfos.id, memberInfos.name);
            expect($.cookie("chatWindows")).toEqual($.toJSON([memberInfos]));
        });

        it("saves information on nonempty cookie", function(){
            // First window
            var memberInfos = {
              "id" : "chat-user-50",
              "name" : "Username Lastname",
              "status" : "online",
              "state" : "opened"
            };
            $.storeWindow(memberInfos.id, memberInfos.name);

            // Second window
            var memberInfos2 = {
              "id" : "chat-user-51",
              "name" : "Username1 Lastname1",
              "status" : "online",
              "state" : "opened"
            };
            $.storeWindow(memberInfos2.id, memberInfos2.name);
            expect($.cookie("chatWindows")).toEqual($.toJSON([memberInfos, memberInfos2]));
        });

        it("removes specified window on cookie with one window", function(){
            // First window
            var memberInfos = {
              "id" : "chat-user-50",
              "name" : "Username Lastname",
              "status" : "online",
              "state" : "opened"
            };
            $.storeWindow(memberInfos.id, memberInfos.name);

            $.removeWindow(memberInfos.id);
            expect($.cookie("chatWindows")).toEqual(null);
        });

        it("removes specified window on cookie with more than one window", function(){
            // First window
            var memberInfos = {
              "id" : "chat-user-50",
              "name" : "Username Lastname",
              "status" : "online",
              "state" : "opened"
            };
            $.storeWindow(memberInfos.id, memberInfos.name);

            // Second window
            var memberInfos1 = {
              "id" : "chat-user-51",
              "name" : "Username1 Lastname1",
              "status" : "online",
              "state" : "closed"
            };
            $.storeWindow(memberInfos1.id, memberInfos1.name);

            // Third window
            var memberInfos2 = {
              "id" : "chat-user-52",
              "name" : "Username2 Lastname2",
              "status" : "online",
              "state" : "opened"
            };
            $.storeWindow(memberInfos2.id, memberInfos2.name);

            $.removeWindow(memberInfos1.id);
            expect($.cookie("chatWindows")).toEqual($.toJSON([memberInfos, memberInfos2]));
        });

        it("changes the status of a specified user", function(){
            // First window
            var memberInfos = {
              "id" : "chat-user-50",
              "name" : "Username Lastname",
              "status" : "online",
              "state" : "opened"
            };
            $.storeWindow(memberInfos.id, memberInfos.name);

            // Second window
            var memberInfos1 = {
              "id" : "chat-user-51",
              "name" : "Username1 Lastname1",
              "status" : "online",
              "state" : "opened"
            };
            $.storeWindow(memberInfos1.id, memberInfos1.name);

            $.changeWindow(memberInfos1.id, "status", "offline");
            memberInfos1["status"] = "offline";
            expect($.cookie("chatWindows")).toEqual($.toJSON([memberInfos, memberInfos1]));
        });

        it("changes the state of a window", function(){
            // First window
            var memberInfos = {
              "id" : "chat-user-50",
              "name" : "Username Lastname",
              "status" : "online",
              "state" : "opened"
            };
            $.storeWindow(memberInfos.id, memberInfos.name);

            // Second window
            var memberInfos1 = {
              "id" : "chat-user-51",
              "name" : "Username1 Lastname1",
              "status" : "online",
              "state" : "opened"
            };
            $.storeWindow(memberInfos1.id, memberInfos1.name);

            $.changeWindow(memberInfos1.id, "state", "closed");
            memberInfos1["state"] = "closed";
            expect($.cookie("chatWindows")).toEqual($.toJSON([memberInfos, memberInfos1]));
        });
    });

    describe("restoring state", function(){
        var memberInfos;
        var memberInfos1;
        beforeEach(function(){
            // First window
            memberInfos = {
              "id" : "chat-user-50",
              "name" : "Username Lastname",
              "status" : "online",
              "state" : "opened"
            };
            $.storeWindow(memberInfos.id, memberInfos.name);

            // Second window
            memberInfos1 = {
              "id" : "chat-user-51",
              "name" : "Username1 Lastname1",
              "status" : "online",
              "state" : "closed"
            };
            $.storeWindow(memberInfos1.id, memberInfos1.name);
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
