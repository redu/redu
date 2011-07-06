(function($){
 $.fn.refreshMobileMask = function(){
    return this.each(function(){
      var $this = $(this);
      $this.mask("+99 (99) 9999-9999", { placeholder:" " });
    });
 };

 jQuery(function(){
   $("#biography .mobile").refreshMobileMask();

   $(document).ajaxComplete(function(){
     $("#biography .mobile").refreshMobileMask();
   });
 });

})($);
