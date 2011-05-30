describe('Chat', function () {
    beforeEach(function () {
        Pusher = function(key, args){}

        Pusher.prototype.subscribe = function(channel){
          var data = { data : "opa" }
          return { bind : function(event, callback) { callback(data); }};
        }
    });

    afterEach(function () {
      // Limpando elementos adicionados ao DOM
      $("#chat-list").remove();
    });


    it('defines buildChat', function () {
        expect(buildChat).toBeDefined();
    });

    describe('initialization', function () {
        var chat, opts;

        beforeEach(function () {
            opts = { key : 'XXX', channel : 'my-channel' };
            chat = buildChat(opts)
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
          "roles" : {
            "teacher" : true,
            "member" : false,
            "administrator" : false,
            "tutor" : false,
          },
          name : "Test user",
          thumbnail : "new/missing_users_thumb_32.png"
        }

        chat.uiAddContact(member);
      });

      it('adds contact to UI', function () {
          expect($("#chat-list ul li").length).toBe(1);
          expect($("#chat-list .name").text()).toBe(member.name);
      });

      it('adds the correct role classes', function() {
        expect($("#chat-list .roles")).toHaveClass("teacher");
      });

      it('creates the user link', function() {
          expect($("#chat-list img").attr("src")).toBe(member.thumbnail);
      });
    });
});

