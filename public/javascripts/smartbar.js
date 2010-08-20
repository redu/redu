
jQuery(document).ready(function() {
    jQuery("#smartbar").jixedbar(); // select element
    
    jQuery("#smartbar a.fire").live('click', function(e){
    	box = "#" + jQuery(this).attr('href').substring(1)
    	
    	jQuery('div.active-messagebox').animate({
	    		height: "0px",
	    		padding: "0px"
	    })
	    jQuery('div.active-messagebox').removeClass('active-messagebox')
	    jQuery("#smartbar a.unfire").removeClass('unfire').addClass('fire')
	    
    	jQuery(box).animate({
	    		height: "229px",
	    		padding: "4px 0 0 4px"
	    })
	    jQuery(box).addClass('active-messagebox')
	    
	    jQuery(this).toggleClass('fire')
	    jQuery(this).toggleClass('unfire')
      
      e.preventDefault()
      
    })
    
    jQuery("#smartbar a.unfire").live('click', function(e){
    	box = "#" + jQuery(this).attr('href').substring(1)
    	
    	jQuery(box).animate({
	    		height: "0px",
	    		padding: "0px"
	    })
	    
	    jQuery(box).removeClass('active-messagebox')
	    
	    jQuery(this).toggleClass('fire')
	    jQuery(this).toggleClass('unfire')
      
      e.preventDefault()
      
    })
  })
