// Exibe todos os comentários
$.fn.exibeComments = function(opts){
  return this.each(function(){
    var $this = $(this);

    $this.live("click", function(e){
      var $responses = $this.parents(".responses");

      // Esconde todas as respostas mais antigas
      if ($responses.hasClass("open")){
        $responses.find(".last-responses").html("Visualizando as últimas respostas...");
        $responses.countComments();
        $responses.find('li').animate(150);
        $responses.groupResponses();
        $responses.removeClass("open");
      }

      // Exibe todas as respostas
      else {
        $responses.find(".last-responses").html("Visualizando todas as respostas...");
        $responses.find("li").slideDown(150, 'swing');
        $this.html("esconder todas as respostas");
        // Adiciona a class open para informar que todas as respostas estão exibidas
        $responses.addClass("open");
      }
    });
  });
};

// Exibe área de criação de respostas
$(".actions .reply-status span").live("click", function(e){
  var $this = $(this);

  $this.parents(".subject-content").find(".create-response").slideToggle(150, 'swing');
});

// Esconde formulário para criação de respostas
$(".create-response .status-buttons .cancel").live("click",function(e){
  var $this = $(this);

  $this.parents(".create-response").slideUp(150, 'swing');
});

// Expande o text-area para a criação de status
$(".create-status textarea").live("click",function(e){
  var $textArea = $(this);
  var $button = $textArea.parent().find(".status-buttons");

  $textArea.animate({ height: 136 }, 150);
  $button.slideDown(150, "swing");
  e.preventDefault();
})

// Cancelar a criação de status
$(".create-status .status-buttons .cancel").live("click", function(e){
  e.preventDefault()
  var $this = $(this);

  $this.parents("form").find("textarea").animate({ height: 30 }, 150);
  $this.parents(".status-buttons").slideUp(150, 'swing');
})

// Agrupa respostas
$.fn.groupResponses = function(opts){
  return this.each(function(){
    var $this = $(this);
    var options = {
      maxResponses : 3
    }
    $.extend(options, opts)

    var $responses = $this.find("li:not(.show-responses)");
    if ($responses.length > options.maxResponses) {
      $responses.filter(":lt(" + ($responses.length - options.maxResponses) + ")").slideUp(150, "swing");
      $(this).find(".show-responses").show();
    }
  });
}

// Agrupa membros
$.fn.groupMembers = function(opts){
  return this.each(function(){
    var $this = $(this);
    var options = {
      elementWidth : 34,
      elementHeight : 40
    }
    $.extend(options, opts)

    var $elements = $this.find("li");
    var width = $this.width();
    var newHeight = (Math.ceil((($elements.length * options.elementWidth) /  width)) *  options.elementHeight);

    // Exibe os elementos agrupados
    $(".link-fake.see-all").live("click",function(e) {

      // Exibe todos os elementos
      if ($this.hasClass("open")) {
        $this.animate({ height: options.elementHeight }, 150);
        $this.removeClass("open");
        $(this).html("+ ver todos");
      }

      // Esconde elementos para agrupar
      else {
        $this.addClass("open");
        $this.animate({ height: newHeight }, 150);
        $(this).html("- esconder todos");
      }
    });
  })
}

//Conta a quantidade de respostas de um post
$.fn.countComments = function(){
  return this.each(function(){
    var $this = $(this);
    var quantity = $this.find(".response").length;
    $this.find(".see-more").html("Mostrar todas as " + quantity + " respostas");
  });
};

$(function() {
  $('.responses').groupResponses();
  $('.grouping-elements').groupMembers();
  $(".responses").countComments();
  $(".responses .see-more").exibeComments();

  // Deixa ícone do contexto do estilo hover ao passar o mouse no link do mesmo, e vice-versa.
  $(".context-icon").each( function(){
    var $this = $(this);
    var $link = $this.parent().find(".context-link");
    var findIconClass = function (classes) {
      for (i = 0; classes.length; i++) {
        if (classes[i].indexOf("icon") !== -1) {
          return classes[i];
        }
      }
    };

    var iconClass = findIconClass($this.attr("class").split(" "));

    // Troca ícone de estado normal para estado hover alterando sua cor
    var iconHoverClass = iconClass.replace("gray", "blue");

    $this.mouseover(function() {
      $link.addClass("context-link");
    });

    $this.mouseout(function() {
      $link.removeClass("context-link");
    });

    $link.mouseover(function() {
      $this.removeClass(iconClass);
      $this.addClass(iconHoverClass);
    });

    $link.mouseout(function() {
      $this.removeClass(iconHoverClass);
      $this.addClass(iconClass);
    });

  })

});