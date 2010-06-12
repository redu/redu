AppConfig.default_mce_options = {
  :theme => 'advanced',
  :browsers => %w{msie gecko safari},
  :theme_advanced_layout_manager => "SimpleLayout",
  :theme_advanced_statusbar_location => "bottom",
  :theme_advanced_toolbar_location => "top",
  :theme_advanced_toolbar_align => "left",
  :theme_advanced_resizing => true,
  :relative_urls => false,
  :convert_urls => false,
  :cleanup => true,
  :cleanup_on_startup => true,  
  :convert_fonts_to_spans => true,
  :theme_advanced_resize_horizontal => false,
  :theme_advanced_buttons1 => %w{bold italic underline separator justifyleft justifycenter justifyright indent outdent separator bullist numlist separator link unlink image media separator undo redo code},
  :theme_advanced_buttons2 => [],
  :theme_advanced_buttons3 => [],
  :plugins => %w{media preview inlinepopups safari autosave},
  #:plugin_preview_pageurl => '../../../../../posts/preview',
  #:plugin_preview_width => "950",
  #:plugin_preview_height => "650",
  :editor_deselector => "mceNoEditor",
  :extended_valid_elements => "img[class|src|flashvars|border=0|alt|title|hspace|vspace|width|height|align|onmouseover|onmouseout|name|obj|param|embed|scale|wmode|salign|style],embed[src|quality|scale|salign|wmode|bgcolor|width|height|name|align|type|pluginspage|flashvars],object[align<bottom?left?middle?right?top|archive|border|class|classid|codebase|codetype|data|declare|dir<ltr?rtl|height|hspace|id|lang|name|style|tabindex|title|type|usemap|vspace|width]",
	:media_strict => false    
  }
  
  
  AppConfig.advanced_mce_options = {
  :theme => 'advanced',
  :browsers => %w{msie gecko safari},
  :width => '100%',
  :height => '377',
  :theme_advanced_layout_manager => "SimpleLayout",
  :theme_advanced_statusbar_location => "bottom",
  :theme_advanced_toolbar_location => "top",
  :theme_advanced_toolbar_align => "left",
  :theme_advanced_resizing => false,
  :relative_urls => false,
  :convert_urls => false,
  :cleanup => true,
  :cleanup_on_startup => true,  
  :convert_fonts_to_spans => true,
  :theme_advanced_resize_horizontal => false,
  :theme_advanced_buttons1 => %w{formatselect fontselect fontsizeselect | bold italic underline strikethrough | justifyleft justifycenter justifyright justifyfull | forecolor backcolor},
 :theme_advanced_buttons2 => %w{cut copy paste | undo redo | search | bullist numlist outdent indent blockquote | link unlink image code },
 :theme_advanced_buttons3 => %w{tablecontrols | hr removeformat visualaid | sub sup | charmap emotions iespell media | print | ltr rtl | fullscreen},
 :theme_advanced_buttons4 => %w{insertlayer moveforward movebackward absolute },
  
  :plugins => %w{layer table advhr safari advimage advlink emotions iespell inlinepopups preview media searchreplace print contextmenu paste directionality fullscreen noneditable visualchars nonbreaking xhtmlxtras wordcount advlist autosave},
  


  #:plugin_preview_pageurl => '../../../../../posts/preview',
  #:plugin_preview_width => "950",
  #:plugin_preview_height => "650",
  :editor_deselector => "mceNoEditor",
  :extended_valid_elements => "img[class|src|flashvars|border=0|alt|title|hspace|vspace|width|height|align|onmouseover|onmouseout|name|obj|param|embed|scale|wmode|salign|style],embed[src|quality|scale|salign|wmode|bgcolor|width|height|name|align|type|pluginspage|flashvars],object[align<bottom?left?middle?right?top|archive|border|class|classid|codebase|codetype|data|declare|dir<ltr?rtl|height|hspace|id|lang|name|style|tabindex|title|type|usemap|vspace|width]",
  :media_strict => false    
  }
  
AppConfig.question_mce_options = {
  :theme => 'advanced',
  :browsers => %w{msie gecko safari},
 # :theme_advanced_layout_manager => "SimpleLayout",
  :theme_advanced_statusbar_location => "bottom",
  :theme_advanced_toolbar_location => "top",
  :theme_advanced_toolbar_align => "left",
  :theme_advanced_resizing => true,
  :relative_urls => false,
  :convert_urls => false,
  :cleanup => true,
  :cleanup_on_startup => true,  
  :convert_fonts_to_spans => true,
  :theme_advanced_resize_horizontal => false,
  :theme_advanced_buttons1 => %w{bold italic underline separator justifyleft justifycenter justifyright indent outdent separator bullist numlist separator link unlink image media separator undo redo code separator asciimath asciimathcharmap asciisvg},
  :theme_advanced_buttons2 => [],
  :theme_advanced_buttons3 => [],
  :plugins => %w{media safari autosave table inlinepopups},
  #:plugins => %w{media safari autosave asciimath asciisvg table inlinepopups},
  :editor_deselector => "mceNoEditor",
  :extended_valid_elements => "img[class|src|flashvars|border=0|alt|title|hspace|vspace|width|height|align|onmouseover|onmouseout|name|obj|param|embed|scale|wmode|salign|style],embed[src|quality|scale|salign|wmode|bgcolor|width|height|name|align|type|pluginspage|flashvars],object[align<bottom?left?middle?right?top|archive|border|class|classid|codebase|codetype|data|declare|dir<ltr?rtl|height|hspace|id|lang|name|style|tabindex|title|type|usemap|vspace|width]",
  :media_strict => false   
  #:AScgiloc => 'http://www.imathas.com/editordemo/php/svgimg.php',          
  #:ASdloc => 'http://www.imathas.com/editordemo/jscripts/tiny_mce/plugins/asciisvg/js/d.svg'
  
}  
  
  
AppConfig.simple_mce_options = {
  #:mode => 'textareas',
  :width => '100%',
  :height => '377',
  :theme => 'advanced',
  :browsers => %w{msie gecko safari},
  :cleanup_on_startup => true,
  :convert_fonts_to_spans => true,
  :theme_advanced_resizing => true, 
  :theme_advanced_toolbar_location => "top",  
  :theme_advanced_statusbar_location => "bottom", 
  :editor_deselector => "mceNoEditor",
  :theme_advanced_resize_horizontal => false,  
  :theme_advanced_buttons1 => %w{bold italic underline separator bullist numlist separator link unlink image},
  :theme_advanced_buttons2 => [],
  :theme_advanced_buttons3 => [],
  :plugins => %w{inlinepopups safari}
  }