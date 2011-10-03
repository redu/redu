(function($){
    // Padrão de spinner
    $(".admin-filter-form").live('ajax:before', function(e){
        var $this = $(this);
        var $target = $(e.target);

        if($this.is($target)){
          var $submit = $(this).find("input[type=submit]");
          $submit.loadingStart({ "className" : "concave-loading" });
        }
    });

    $(".admin-filter-form").live('ajax:complete', function(){
        $(this).find("input[type=submit]").loadingComplete({ "className" : "concave-loading" });
    });

    // Colorindo tabela de roles
    $.fn.refreshRoleTable = function(){
      return $("#environment-manage .admin-role-table tr:even").addClass("even");
    };

    $(document).ready(function(){
        $(document).refreshRoleTable();

        $(document).ajaxComplete(function(){
            $(document).refreshRoleTable();
        });
    });
})(jQuery);
