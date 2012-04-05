$(document).ready(function(){
  $('.create-status.inform-my-status .status.textarea').keyup(function(e){
    if(e.which == 13 | e.which == 32) {
    var text = $(this).val();
    var regex = /(\b(((https?|ftp|file):\/\/)|(www))[\-A-Z0-9+&@#\/%?=~_|!:,.;]*[\-A-Z0-9+&@#\/%=~_|])/ig;
    var resultArray = text.match(regex);
      if(resultArray != null){
        link = resultArray[0];
        console.log(link);
        var url = escape(link);
        var key = '1068f47e735911e181904040d3dc5c07';
        var api_url = 'http://api.embed.ly/1/oembed?key=' + key + 
                      '&url=' + url;
                      //+ '&callback=?';
        //jQuery JSON call
        $.getJSON( api_url, {crossDomain:  true}, function(json) {
            var html = json.html;
            //$('#videodiv').html(html);
            console.log(json);
        });
      }
    }
  });
});
