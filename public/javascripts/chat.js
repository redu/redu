/*
var mychat = buildChat({
    key : 'XXX',
    channel : '123',
    timeout : '123',
    endPoint : 'httto' });
*/

// Constrói um novo objeto Chat
var buildChat = function(opts){
  var pusher;
  var config = {};
  var $userList = $("<div/>", { id : "chat-list" }).append("<ul/>");

  var that = {
    // Inicializa o pusher e mostra a barra de chat
    init : function(){
      $("body").append($userList);
      // var pusher = new Pusher('f786a58d885e7397ecaa');
      // var channel = pusher.subscribe("teste");
      // channel.bind("pusher:subscription_succeeded", function(data){
      //     console.log(data);
      // });
      this.subscribeMyChannel();

    },
    // Inscreve no canal do usuário logado
    subscribeMyChannel : function(){},
    // Increve no canal dado
    subscribeNewContact : function(channel){},
    // Desinscreve do canal dado
    unsubscribeContact : function(channel){},
    // Adiciona a lista de contatos
    uiAddContact : function(member){},
    // Remove da lista de contatos
    uiRemoveContact : function(userId){},
  }

  return that;
}

