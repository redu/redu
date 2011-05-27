// $(function(){
//     // Requisiçõe c/ header pjax p/ todos os links não remotos
//     $("a:not([data-remote])").pjax("#content", { timeout: null });
//
//     var Chat = {
//       show : function(){
//         var $chatBar = $("<div/>", { 'id' : 'chat-bar' });
//         $("body").append($chatBar);
//       }
//     };
//
//     Chat.show();
//
//     // Inicializa o objeto pusher e exibe a lista de contatos
//     Chat.init(API-KEY)
//
//     // Inscrever no seu canal
//     Chat.subscribe('presence-%user')
//
//     // Preenche a lista de contatos
//     Chat.loadContacts()
//
// });

var buildChat = function(opts){
  var generateName = function(num){
      return "presence-x";
  }

  var that = {
    pusher : ''
    init : function(){
      this.pusher = new Pusher(this.key);
    },
    key : opts.key || 'PADRAO',
    subscribe : function(){
    },
    loadContacts : function(){
    }
  }

  return that;
}

var meuChat = rchat({key : '2293'});
