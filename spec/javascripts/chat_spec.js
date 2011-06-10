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
                chat = buildChat(opts)
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
    });
