$(document).ready(function(){

  /*
    Flow's javascript 
  */
  
  jQuery.ajaxSetup({ 
    'beforeSend': function(xhr) {xhr.setRequestHeader("Accept", "text/javascript")}
  })
  
  /* Toggles status indicator */
  $.fn.toggleSpinner = function(){
    if ($(this).find("img.spinner").length == 0) {
      $(this).prepend("<img class='spinner' src='/images/spinner.gif' />")
    }else{
      $(this).find("img.spinner").remove()
    }
  }
  
  /* Serializes form data and submits */
  $("ul.activities div.question form").submit(function(e){
    $(this).toggleSpinner()
    
    $.post(this.action, $(this).serialize(), null, "script")
    e.preventDefault()
  })
    
})
