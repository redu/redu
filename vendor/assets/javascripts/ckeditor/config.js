/*
   Copyright (c) 2003-2010, CKSource - Frederico Knabben. All rights reserved.
   For licensing, see LICENSE.html or http://ckeditor.com/license
   */

CKEDITOR.on( 'dialogDefinition', function( ev )
    {
    // Take the dialog name and its definition from the event data.
    var dialogName = ev.data.name;
    var dialogDefinition = ev.data.definition;

    // Check if the definition is from the dialog we're
    // interested in (the 'link' dialog).
    if ( dialogName == 'image' )
    {
    // Remove the 'Advanced', 'Link' and 'Upload' tabs from the 'Image' dialog.
    dialogDefinition.removeContents( 'advanced' );
    dialogDefinition.removeContents( 'Link' );
    dialogDefinition.removeContents( 'Upload' );
    }
    });

CKEDITOR.editorConfig = function( config )
{
  config.PreserveSessionOnFileBrowser = true;

  // Define changes to default configuration here. For example:
  config.language = 'en';
  // config.uiColor = '#AADC6E';

  //config.ContextMenu = ['Generic','Anchor','Flash','Select','Textarea','Checkbox','Radio','TextField','HiddenField','ImageButton','Button','BulletedList','NumberedList','Table','Form'] ;

  config.height = '200px';
  config.width = '600px';

  //config.resize_enabled = false;
  //config.resize_maxHeight = 2000;
  //config.resize_maxWidth = 750;

  //config.startupFocus = true;

  // works only with en, ru, uk languages
  config.extraPlugins = "embed,attachment";

  config.toolbar = 'Easy';

  config.toolbar_Easy =
    [
    ['Preview','-','Templates'],
    ['Cut','Copy','Paste','PasteText','PasteFromWord'],
    ['Undo','Redo','-','Find','-','SelectAll','RemoveFormat'],
    ['Bold','Italic','Underline','Strike','-','Subscript','Superscript'],
    ['NumberedList','BulletedList','-','Outdent','Indent','Blockquote'],
    ['JustifyLeft','JustifyCenter','JustifyRight','JustifyBlock'],
    ['Link','Unlink','Anchor'],
    ['Image','Table','HorizontalRule','Smiley','SpecialChar','PageBreak'],
    '/',
    ['Styles','Format','Font','FontSize'],
    ['TextColor','BGColor'],
    ['Maximize','-','About']
      ];
};
