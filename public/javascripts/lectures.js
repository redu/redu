$(function(){
    $overlay = $("<div/>", { 'id' : 'lights_dimmed', 'class' : 'clearfix'}).hide();
    $("body").prepend($overlay);

    // Luzes
    $("#lights").toggle(function(e){
        var docHeight = $(document).height();

        $(".student-actions").css("position", "relative");
        $(".stage").css("position", "relative");
        $(".statuses-wrapper").css("position", "relative").css("backgroundColor", "white");
        $("#lights_dimmed").css("height", docHeight).fadeIn();
        $(this).html("Acender luzes");
        e.preventDefault();
    },
    function(){
        $("#lights_dimmed").fadeOut();
        $(this).html("Apagar luzes");
    });

    $(".statuses-wrapper").live("click", function(){
       var docHeight = $(document).height();
       $("#lights_dimmed:visible").css("height", docHeight)
    });

    $("#do_lecture").live("ajax:before ajax:complete", function(){
        $(this).find("label[for='Aula_finalizada']").loadingToggle();
    });
});
