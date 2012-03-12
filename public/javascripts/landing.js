$(function() {
    $("body").noisy({
        "intensity": 1,
        "size": "400",
        "opacity": 0.079,
        "fallback":"../public/images/t-noisy.png",
        "monochrome": true
    }).css("background-color", "#e6e6e6");

    $("#user-login").click(function(){
      if($(this).val() == "Digite seu login e, abaixo, sua senha"){
        $(this).val("");
      }
    });

    $("#user-login").blur(function(){
      if($(this).val() == ""){
        $(this).val("Digite seu login e, abaixo, sua senha");
      }
    });
});
