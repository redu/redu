(function($){

    // Partners: Gerando slugs no campo de endereço eletronico
    $.fn.partnerSlugs = function(){
        var $path, $name;
        $path = $("#partner_environment_association_environment_attributes_path");
        $name = $("#partner_environment_association_environment_attributes_name");

        $path.bind('keyup blur', function(e){
            $(this).val($(this).slug());
        });
        $name.bind('keyup blur', function(e){
            $path.val($(this).slug());
        });
    };

    $(document).ready(function(){
        $(this).partnerSlugs();
        $(this).ajaxComplete(function(){ $(this).partnerSlugs() });
    });

})(jQuery);
