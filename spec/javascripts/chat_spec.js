describe('Chat', function () {
    beforeEach(function () {
        Pusher.prototype.subscribe = function(channel_name) {
          this.send_event('pusher:subscribe', {
              channel : channel_name,
              auth : '12345',
              channel_data : { 'opa' : '123' }
          });
          var channel = this.channels.add(channel_name, this);
          console.log('olhjae');
          return channel;
        }
    });

    it('defines buildChat', function () {
        expect(buildChat).toBeDefined();
    });

    describe('initialization', function () {
        var chat;

        beforeEach(function () {
            chat = buildChat({ key : 'XXX', channel : 'my-channel' })
        });

        it('defines init', function () {
            expect(chat).toBeDefined();
        });

        it('shows the user list', function() {
            chat.init();
            //expect($("#chat-list ul")).toExist();
            //expect($("#teste")).toExist();
        });

    });

});

