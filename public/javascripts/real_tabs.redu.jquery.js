(function($){
 $.fn.refreshRealTabs = function(){
    return this.each(function(){
      var $this = $(this);

      // Switch tabs and urls
      $this.tabs();
      $this.bind('tabsselect', function(event, ui){
        window.location = ui.tab.href;
      });
    });
 };

 jQuery(function(){
   $(".subtabs").refreshRealTabs();

   $(document).ajaxComplete(function(){
     $(".subtabs").refreshRealTabs();
   });
 });

})($);



