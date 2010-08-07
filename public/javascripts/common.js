function limitChars(textid, limit, infodiv){
    var text = $('#' + textid).val();
    var textlength = text.length;
    if (textlength > limit) {
       // $('#' + infodiv).html('You cannot write more then ' + limit + ' characters!');
        $('#' + textid).val(text.substr(0, limit));
        return false;
    }
    else {
        $('#' + infodiv).html('(' + (limit - textlength) + ')');
        return true;
    }
}

$(document).ready(function(){
	


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
    
    $(".question-action a").click(function(e){
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
    //$('body').click(function(event){
    //    if (!$(event.target).closest("#header div.user-actions a.pandora").length) {
    //       $("#user-settings").slideUp('slow')
    //    };
    //    });



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
	
})
	
	/*
	 * AJAX
	 */
	
    jQuery.ajaxSetup({
        'beforeSend': function(xhr){
            xhr.setRequestHeader("Accept", "text/javascript")
        }
    })
