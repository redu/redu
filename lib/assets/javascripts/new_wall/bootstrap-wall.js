// Copiado do bootstrap sem modificações.


// Exibe formulário para criação de status.
$(document).on("focusin", ".status-tab textarea", function() {
  var $textArea = $(this);

  if (!$textArea.data("open")) {
    $textArea
      .animate({ height: "122px" }, 150, "swing", function() {
        var $buttons = $textArea.closest(".status-tab").find(".status-buttons");

        $buttons.slideDown(150, "swing");
      })
      .data("open", true);
  }
});

// Cancela a criação de status.
$(document).on("click", ".create-status .cancel", function() {
  var $cancelButton = $(this);
  var $createStatus = $cancelButton.closest(".create-status");
  var $statusButtons = $createStatus.find(".status-buttons");
  var $preview = $createStatus.find(".post-resource");
  var $textArea = $createStatus.find("textarea");

  $statusButtons.slideUp(150, "swing", function() {
    $textArea
      .animate({ height: 32 }, 150, "swing", function() {
        $preview.slideUp(150, "swing", function() {
          $preview.remove();
        });
      })
      .data("open", false);
  });
});

// Exibe formulário para criação de respostas.
$(document).on("click", ".status .reply-status .link-secondary", function() {
  var $subjectContent = $(this).closest(".subject-content");
  var $createResponse = $subjectContent.find(".create-response");
  var $textArea = $createResponse.find("textarea");

  $createResponse.slideToggle(150, "swing");
  $textArea.focus();
});

// Esconde formulário para criação de respostas.
$(document).on("click", ".status .cancel", function() {
  var $cancelButton = $(this);
  var $createStatus = $cancelButton.closest(".create-response");
  var $preview = $createStatus.find(".post-resource");

  $createStatus.slideUp(150, "swing", function() {
    $preview.remove();
  });
});

// Expande/minimiza as respostas dos comentários.
$(document).on("click", ".status .see-more", function() {
  var $link = $(this);
  var $status = $link.closest(".status");
  var $lastResponses = $status.find(".last-responses");
  var $responses = $status.find(".responses").children().filter(":not(.show-responses)");
  var totalResponses = $responses.length;

  if (!$link.data("open")) {
    // Mostra as respostas que estavam escondidas.
    $responses.filter(":hidden").slideDown(150, "swing");
    $link.html("Esconder as primeiras respostas")
    $lastResponses.html("Visualizando todas as respostas...");
    $link.data("open", true);
  } else {
    // Deixa somente as 3 últimas visíveis.
    $responses.filter(":lt(" + (totalResponses - 3) + ")").slideUp(150, "swing");
    $link.html("Mostrar todas as " + totalResponses + " respostas");
    $lastResponses.html("Visualizando as últimas respostas...");
    $link.data("open", false);
  }
});

// Expande/minimiza os membros.
$(document).on("click", ".status-list .see-all", function() {
  var $link = $(this);
  var $groupingElements = $link.closest(".status").find(".grouping-elements");

  if (!$link.data("open")) {
    $groupingElements.animate({ height: $groupingElements[0].scrollHeight }, 150, "swing");
    $link
      .html("- Esconder todos")
      .data("open", true);
  } else {
    $groupingElements.animate({ height: 40 }, 150, "swing");
    $link
      .html("+ Ver todos")
      .data("open", false);
  }
});

// Agrupa as respostas.
$.fn.groupResponses = function(opts) {
  return this.each(function() {
    var options = {
      maxResponses : 3
    }
    $.extend(options, opts)
    var $this = $(this);
    var $responses = $this.children(":not(.show-responses)");

    if ($responses.length > options.maxResponses) {
      $responses.filter(":lt(" + ($responses.length - options.maxResponses) + ")").slideUp(150, "swing");
      $(this).find(".show-responses").show();
     } else {
      $this.find(".show-responses").hide();
      $responses.first().find("hr").hide();
    }
  });
}

// Conta a quantidade de respostas de um status e atualiza a legenda.
$.fn.countComments = function() {
  return this.each(function() {
    var $responses = $(this);
    var quantity = $responses.find(".response").length;
    var $seeMore = $(".see-more");

    $seeMore.html("Mostrar todas as " + quantity + " respostas");
  });
};

$(function() {
  $(".responses").groupResponses();
});