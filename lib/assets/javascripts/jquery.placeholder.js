// Fonte: http://calebogden.com/ms/placeholder/

$.fn.placeholder = function(options) {
    
  var settings = {
  };
  
  return this.each(function() {
  
    if ( options ) {
      $.extend( settings, options );
    }
  
    var base = $(this);
    
    /* Replaced all occurences of "on()" with "bind()", since "on()" only
       works with jQuery +1.7 and it was causing error with 1.6.1. */
    
    var wrap = $('<span class="ui-placeholder-wrap" />');
    var placeholder = $('<span class="ui-placeholder" />')
      .bind("click.placeholder",function(){
        $(this).siblings('input').focus();
        $(this).parent().addClass('ui-placeholder-active');
      })
      .html(base.attr('placeholder'));
    base
      .attr("placeholder","")
      .wrap(wrap)
      .after(placeholder)
      .bind("focus.placeholder focusout.placeholder",function(){
        if ($(this).val() == "") {
          $(this)
            .siblings('.ui-placeholder')
            .fadeIn('fast');
        }
        $(this)
          .parent()
          .toggleClass('ui-placeholder-active');
      })
      .bind('keydown.placeholder', function(e){
        e.stopPropagation();
        setTimeout(function(){
        
        
        if (base.val() == "") {
        base
          .siblings('.ui-placeholder')
          .fadeIn(250);
        } else {
        base
          .siblings('.ui-placeholder')
          .hide();
        }
        
        },50);
      });
    
    if (base.val() !== "") {
      placeholder.hide();
    }
  
  
  });

};