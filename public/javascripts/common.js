/*
 * TIMER
 */
jQuery.fn.delay = function(time,func){
  return this.each(function(){
      setTimeout(func,time);
      });
};


function limitChars(textclass, limit, infodiv){
  var text = $('.' + textclass).val();
  var textlength = text.length;
  if (textlength > limit) {
    // $('#' + infodiv).html('You cannot write more then ' + limit + ' characters!');
    $('.' + textclass).val(text.substr(0, limit));
    return false;
  } else {
    $('.' + infodiv).html('(' + (limit - textlength) + ')');
    return true;
  }
}

$(document).ready(function(){
    // Paginações em AJAX
    $(".pagination a").live("click",
      function() {
      $(".pagination ul").toggle();
      $.get(this.href, null, function(){ $(".pagination ul").toggle() }, "script");
      return false;
    });


    // hoverdivs "click off" (somem ao clicar fora)
    $('body').click(function(event){
      if (!$(event.target).closest('.hoverdiv').length) {
      $('.hoverdiv').hide();
      };
      });


    // message box fades out after 5secs
    $('#flash').delay(5000, function(){$('#flash').fadeOut()});


    // User box

    $("#group .sidebar ul.sub-groups li ul, #group .sidebar ul.sub-groups li a.more").hide()

      $("#group .sidebar ul.sub-groups > li a.sb").click(function(e){
          e.preventDefault()
          $(this).toggleClass('opened')
          $(this).next().slideToggle()
          $(this).next().next().toggle()
          })

    $("ul.sortable").sortable({
      placeholder: 'ui-state-highlight'
    });

    $("ul.sortable").disableSelection()


$(".question-action a").live('click', function(e){
    $(this).next("div.answer:first").slideToggle()
    e.preventDefault()
    })
$("div.post-activity").tabs({fx : { opacity : 'toggle'}})

$("input[title], textarea[title]").each(function(){
    if($(this).val() === ''){
    $(this).val($(this).attr('title'))
    }

    $(this).focus(function(){
      if($(this).val() === $(this).attr('title')){
      $(this).val('').toggleClass('inner-label')
      }
      })

    $(this).blur(function(){
      if($(this).val() === ''){
      $(this).val($(this).attr('title')).toggleClass('inner-label')
      }
      })
    })

i = 2
$("form.post-poll span.add").click(function(){
    $(this).before("<input type=\"text\" name=\"choice_"+i+"\" title=\"Alternativa "+i+"\"/>")
    i++
    })

$("ul.groups > li:odd").addClass("odd")

$("input[title], textarea[title]").each(function(){
    if($(this).val() === ''){
    $(this).val($(this).attr('title'))
    }

    $(this).focus(function(){
      if($(this).val() === $(this).attr('title')){
      $(this).val('').toggleClass('inner-label')
      }
      })

    $(this).blur(function(){
      if($(this).val() === ''){
      $(this).val($(this).attr('title')).toggleClass('inner-label')
      }
      })
    })

i = 2
$("form.post-poll span.add").click(function(){
    $(this).before("<input type=\"text\" name=\"choice_"+i+"\" title=\"Alternativa "+i+"\"/>")
    i++
    })

$("ul.groups > li:odd").addClass("odd")

  $("#header div.user-actions a.pandora").click(function(e){
      e.preventDefault()
      var id = $(this).attr('href')
      $(id).slideToggle()
      $(this).toggleClass("opened")
      $(this).toggleClass("closed")

      })

// header "click off"
$('body').click(function(event){
    if (!$(event.target).closest('#user-settings').length) {
    $('#user-settings').hide();
    };
    });




/*
   Learn/teach dropdown
   */

$("#teach span.call ul.options").hide()
$("#teach span.call span.option").toggle(
    function(){
    $(this).next("ul.options:first").slideToggle("fast")
    },
    function(){
    $(this).next("ul.options:first").slideToggle("fast")
    }
    )

/*
   Default list style (odd lines coloring)
   */

$("ul.default > li:odd").addClass("odd")
$("ul.default > li:even").addClass("even")
$("ul.activities > li:first").addClass("first_item")

$(".tooltipable").tipTip({
  defaultPosition: "top",
});

})

/*
 * AJAX
 */

jQuery.ajaxSetup({
    'beforeSend': function(xhr){
    xhr.setRequestHeader("Accept", "text/javascript")
    }
    })

/* Create path */
function stripAccent(str) {
  var rExps = [{ re: /[\xC0-\xC6]/g, ch: 'A' },
      { re: /[\xE0-\xE6]/g, ch: 'a' },
      { re: /[\xC8-\xCB]/g, ch: 'E' },
      { re: /[\xE8-\xEB]/g, ch: 'e' },
      { re: /[\xCC-\xCF]/g, ch: 'I' },
      { re: /[\xEC-\xEF]/g, ch: 'i' },
      { re: /[\xD2-\xD6]/g, ch: 'O' },
      { re: /[\xF2-\xF6]/g, ch: 'o' },
      { re: /[\xD9-\xDC]/g, ch: 'U' },
      { re: /[\xF9-\xFC]/g, ch: 'u' },
      { re: /[\xE7]/g, ch: 'c' },
      { re: /[\xC7]/g, ch: 'C' },
      { re: /[\xD1]/g, ch: 'N' },
      { re: /[\xF1]/g, ch: 'n'}];

  for (var i = 0, len = rExps.length; i < len; i++)
    str = str.replace(rExps[i].re, rExps[i].ch);

  return str;
}

jQuery.fn.slug = function() {
  var $this = $(this);
  var slugcontent = stripAccent($this.val());
  var slugcontent_hyphens = slugcontent.replace(/\s+/g,'-');
  return slugcontent_hyphens.replace(/[^a-zA-Z0-9\-]/g,'').toLowerCase();
};

/* Environment */

/* Hack para o IE no dropdown de environments */
$('#environment li.env-show').hover(
    function() { $('ul', this).css('display', 'block'); },
    function() { $('ul', this).css('display', 'none'); });

