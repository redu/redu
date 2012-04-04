$(document).ready(function(){
  $('.status.textarea').keyup(function(e){
    if(e.which == 13 | e.which == 32) {
    var text = $(this).val();
    var regex = /(\b(((https?|ftp|file):\/\/)|(www))[\-A-Z0-9+&@#\/%?=~_|!:,.;]*[\-A-Z0-9+&@#\/%=~_|])/ig;
    var resultArray = text.match(regex);
    console.log(resultArray);
    }
  });
});