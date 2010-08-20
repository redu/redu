LazyLoad.loadOnce('/javascripts/tinymce_hammer.js', function() {
  tinyMCE.init({
    mode : 'exact',
    elements : 'blog_post_body,blog_commentbody',
    plugins : 'safari,table,paste,asciimath,asciisvg,inlinepopups',
    paste_convert_headers_to_strong : true,
    paste_convert_middot_lists : true,
    paste_remove_spans : true,
    paste_remove_styles : true,
    paste_strip_class_attributes : true,
    theme : 'advanced',
    theme_advanced_toolbar_align : 'left',
    theme_advanced_toolbar_location : 'top',
    theme_advanced_buttons1 : 'undo,redo,cut,copy,paste,pastetext,|,bold,italic,strikethrough,blockquote,charmap,bullist,numlist,removeformat,|,link,unlink,image,|,cleanup,code',
    theme_advanced_buttons2 : 'asciimath,asciimathcharmap,asciisvg',
    theme_advanced_buttons3 : '',
	
	AScgiloc : 'http://www.imathas.com/editordemo/php/svgimg.php',			      //change me  
    ASdloc : 'http://www.imathas.com/editordemo/jscripts/tiny_mce/plugins/asciisvg/js/d.svg'
	
  });
});