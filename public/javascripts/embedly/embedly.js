$(document).ready(function(){
  $('.create-status.inform-my-status .status.textarea').keyup(function(e){
    if(e.which == 13 | e.which == 32) {
      var text = $(this).val();
      var regex = /(\b(((https?|ftp|file):\/\/)|(www))[\-A-Z0-9+&@#\/%?=~_|!:,.;]*[\-A-Z0-9+&@#\/%=~_|])/ig;
      var resultArray = text.match(regex);
      if(resultArray != null){
        link = resultArray[0];
        var url = escape(link);
        var key = '1068f47e735911e181904040d3dc5c07';
        var api_url = 'http://api.embed.ly/1/oembed?key=' + key +
    '&url=' + url;
  //+ '&callback=?';
  //jQuery JSON call
  $.getJSON( api_url, {crossDomain:  true}, function(json) {
    console.log(json);

    var title = "";
    var description = "";
    var thumbnail_content = "";
    var thumbnail_navigation = "";
    var resource_inputs = "";
    var thumbnail_list = [];

    if(json.title != null) {
      title = json.title;
      resource_inputs = resource_inputs + '<input type="hidden" name="title" value="'+ title +'"/>';
    }
    if(json.description != null) {
      description = json.description;
      resource_inputs = resource_inputs + '<input type="hidden" name="description" value="'+ description + '"/>';
    }

    //Process thumbnails
    if(json.thumbnail_url != null) {
      if(json.thumbnail_url instanceof Array){
        for(el in json.thumbnail_url){
          thumbnail_list.push(json.thumbnail_url[el].url);
        }
        thumbnail_navigation = '<span class="last">'+
          '<span class="arrow">L</span>'+
          '</span><span class="next">'+
          '<span class="arrow">N</span></span>';
      } else {
        thumbnail_list.push(json.thumbnail_url);
      }
      resource_inputs = resource_inputs + '<input type="hidden" name= "thumbnail_list" value="'+ thumbnail_list.toString() +'"/>';

      thumbnail_content = '<div class="thumbnail">'+
        '<span class="preview-link">'+
        '<img id="thumbnail-0" src="'+thumbnail_list[0] +'"/>"</span>'+
        thumbnail_navigation +
        '<span class="remove">'+
        '<span class="arrow">R</span>'+
        '</span>'+
        '</div>';
    }

    //Preview box
    $('fieldset .new-post.vis-new-post').remove();
    $('<div class="new-post vis-new-post">'+
        resource_inputs + thumbnail_content +
        '<div class="description">'+
        '<span class="close icon-small icon-delete-gray_8_10">Close</span>'+
        '<h2 class="title">'+title+'</h2>'+
        '<h3 class="link">'+json.url+'</h3>'+
        '<p>'+description+'</p>'+
        '</div>'+
        '</div>'
     ).insertAfter('textarea.status.textarea');

    //close embedded content
    $('.description span.close.icon-small').click(function(){
      $('fieldset .new-post.vis-new-post').slideUp();
    });

    //next thumbnail
    $('.thumbnail span').click(function(){
      if($(this).hasClass('remove')){
        $('.thumbnail').fadeOut();
      } else {
        var img = $('.thumbnail .preview-link img');
        var img_id = img[0].id.split('-')[1];
        if($(this).hasClass('next')){
          var next_id = parseInt(img_id) + 1;
          if(next_id == thumbnail_list.length) { next_id = next_id -1; }
        } else {
          var next_id = parseInt(img_id) - 1;
          if(next_id < 0) { next_id = 0; }
        }
        img.attr('src', thumbnail_list[next_id]);
        img.attr('id', 'thumbnail-' + next_id);
      }
    });
  });
      }
    }
  });
});
