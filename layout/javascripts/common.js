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
    
    $(".tabs").tabs();
    
    $(".question-action a:first").click(function(e){
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
})
