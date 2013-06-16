$(function(){
    var utils = {};

    utils.fileInputs = function() {
      var $this = $(this),
          $val = $this.val(),
          valArray = $val.split('\\'),
          newVal = valArray[valArray.length-1],
          $button = $this.siblings('.button-primary, .button-default, .upload-button'),
          $fakeFile = $this.siblings('.file-holder');

      if(newVal !== '') {
        $button.text('Escolhido');
        $fakeFile.remove();
        $button.after('<span class="file-holder">' + newVal + '</span>');
      }
    };

    utils.toggleFields = function(el){
      var $row = $(el).parents("li:first");
      $row.find(".folder-name, .rename-folder").toggle();
    };

    utils.toggleLoader = function(){
      $("#file_list table").toggle();
      $("#loading-files").toggle();
    };

    utils.setup = function(){
      var $this = $(this);
      $this.val("");

      utils.refresh();
    };

    utils.refresh = function(){
      $(document).ajaxComplete(function(){
        $("table.common tr:even").addClass("odd");
      });
    };

    // Setting up
    utils.setup();

    // Criar diretorio
    $(".new-folder .button-default").live("click", function(e){
        $(".new-file-inner:visible", "#folder-admin").slideUp("fast");
        $(this).next(".holder").slideToggle("fast");

        e.preventDefault();
    });

    // Upload
    $(".new-file .upload-button").live("click", function(e){
        $(".new-folder-inner:visible", "#folder-admin").slideUp("fast");
        $(this).next(".holder").slideToggle("fast");
        e.preventDefault();
    });

    // Fake input
    // $("#folder-admin .new-file .file-wrapper input[type=file]").live('change focus click', utils.fileInputs);

    // Rename
    $(".rename, .rename-folder .cancel").live("click", function(e){
        utils.toggleFields(this);
        e.preventDefault();
    });
});
