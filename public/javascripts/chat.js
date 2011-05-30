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

  $.fn.addContact = function(opts){
    return this.each(function(){
        var $this = $(this);
        var $li = $("<li/>").appendTo($this);
        var $role = $("<span/>", { "class" : "roles" }).appendTo($li);
        $("<img/>", { "src" : opts.thumbnail, "class" : "avatar" }).appendTo($this);

        // Adicionando classe p/ papeis true
        for(var key in opts.roles){
          if(opts.roles[key]){ $role.addClass(key); }
        }

        $("<span/>", { 'class' : "name" }).text(opts.name).appendTo($this);
    });
  };

  $.extend(config, opts)

  var that = {
    // Inicializa o pusher e mostra a barra de chat
    init : function(){
      // Initicializando layout
      $("body").append($userList);
      pusher = new Pusher(config.key);
    },
    // Inscreve no canal do usuário logado
    subscribeMyChannel : function(){},
    // Increve no canal dado
    subscribeNewContact : function(channel){},
    // Desinscreve do canal dado
    unsubscribeContact : function(channel){},
    // Adiciona a lista de contatos
    uiAddContact : function(member){
      $userList.find("ul").addContact(member);
    },
    // Remove da lista de contatos
    uiRemoveContact : function(userId){},
  }

  return that;
}

