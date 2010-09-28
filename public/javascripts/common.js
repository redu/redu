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
    }
    else {
        $('.' + infodiv).html('(' + (limit - textlength) + ')');
        return true;
    }
}

$(document).ready(function(){


	 // Paginações em AJAX
	  $(".pagination a").live("click", function() {
	    $(".pagination").html("Carregando...");
	    $.get(this.href, null, null, "script");
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

   // $(".tabs").tabs(); // esta funcao é chamada em cada view que eh usada pois é instanciada diferentemente

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

})

	/*
	 * AJAX
	 */

    jQuery.ajaxSetup({
        'beforeSend': function(xhr){
            xhr.setRequestHeader("Accept", "text/javascript")
        }
    })


