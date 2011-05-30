describe('Chat', function () {
    beforeEach(function () {
        Pusher = function(key, args){}

        Pusher.prototype.subscribe = function(channel){
          var data = { data : "opa" }
          return { bind : function(event, callback) { callback(data); }};
        }
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

        it('shows the user list', function() {
            spyOn(chat, "subscribeMyChannel");

            chat.init();
            expect(chat.subscribeMyChannel).toHaveBeenCalled();
        });

    });

});

