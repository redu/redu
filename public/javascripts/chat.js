$(function(){
    // Requisiçõe c/ header pjax p/ todos os links não remotos
    $("a:not([data-remote])").pjax("#content", { timeout: null });

    var Chat = {
      show : function(){
        var $chatBar = $("<div/>", { 'id' : 'chat-bar' });
        $("body").append($chatBar);
      }
    };

    Chat.show();
});
