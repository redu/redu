module UploadifyRailsHelper
  
  def uploadify_options(options = {})
    @uploadify_options ||= {:dialog_file_description => "Files",
                            :allowed_extensions      => [:jpg, :jpeg, :gif, :png],
                            :max_size                => 100.megabytes,
                            :allow_multiple_files    => true,
                            :format                  => "json",
                            :url                     => nil, # required
                            :id                      => nil, # required
                            :button_text             => "Browse",
                            :cancel_image            => "/images/cancel.png",
                            :method                  => 'POST',
                            :fields                  => nil, #accepts an Array of field ids to include
                            :uploader                => '/javascripts/uploadify/uploadify.swf' }.merge(options)
  end
  
  def javascript_uploadify_tag(options = {})
    uploadify_options(options) #sets uploadify options
    javascript_tag(%(
    $(document).ready(function() {
      $('##{uploadify_options[:id]}').uploadify({
        uploader      : '#{uploadify_options[:uploader]}',
        method        : '#{uploadify_options[:uploader]}',
        script        : '#{uploadify_options[:url]}',
        fileDataName  : $('##{uploadify_options[:id]}')[0].name, // Extract correct name of upload field from form field
        cancelImg     : '#{uploadify_options[:cancel_image]}',
        #{%(buttonImg : '#{uploadify_options[:button_image]}',) if uploadify_options[:button_image]}
        buttonText    : '#{uploadify_options[:button_text]}',
        fileDesc      : '#{uploadify_options[:dialog_file_description]} (#{allowed_extensions})',
        fileExt       : '#{allowed_extensions}',
        sizeLimit     : #{uploadify_options[:max_size]},    
        multi         : #{uploadify_options[:allow_multiple_files] },
        onComplete    : function(event, queueID, fileObj, response, data) { eval(response) },
        onAllComplete : function(event, data){
          $('#uploadify_cancel').hide('blind');
          $('#uploadify_submit').show('blind');      
        },
        onSelect: function(event, queueID, fileObj){
          if (fileObj.size > #{uploadify_options[:max_size]}) {
            alert('The image' + fileObj.name + ' is too large.')
            return false;
          }
        },
        scriptData  : {
            'format'                  : '#{uploadify_options[:format]}',
            '#{get_session_key_name}' : encodeURIComponent('#{get_session_key}'),
            'authenticity_token'      : encodeURIComponent('#{get_authenticity_token}')
        }
      });
    }
    );))
  end
  
  def render_uploadify(options = {})
    javascript_tag("window._token = '#{get_authenticity_token}'") <<
    javascript_include_tag("uploadify/swfobject") << 
    javascript_include_tag("uploadify/jquery.uploadify.v2.1.0.min") <<
    javascript_uploadify_tag(options)  
  end
  
  def uploadify_cancel(text = "Cancel", options = {})
    link_to_function text, {:id => "uploadify_cancel", :style => "display:none"}.merge(options) do |link|
      link << "$('##{uploadify_options[:id]}').uploadifyClearQueue();
               $('#uploadify_cancel').hide();
               $('#uploadify_submit').show()"
    end
  end
  
  def uploadify_submit(text = "Upload", options = {})
    link_to_function text, {:class => "button", :id => "uploadify_submit"}.merge(options) do |page|
      page << generate_updates_for_script_data
      page << "$('##{uploadify_options[:id]}').uploadifyUpload();
               $('#uploadify_submit').hide();
               $('#uploadify_cancel').show()"
    end
  end

protected  
  
  def generate_updates_for_script_data
    options = uploadify_options[:fields]
    return if options.nil?
    options.collect do |id|
      %( var #{id}_hash = {};
         #{id}_hash[$('##{id}')[0].name] = $('##{id}')[0].value;
         $('##{uploadify_options[:id]}').uploadifySettings( 'scriptData', #{id}_hash ); )
    end.join("\n")
  end
  
  def get_authenticity_token
    u form_authenticity_token if protect_against_forgery?
  end
  
  def get_session_key_name
    ActionController::Base.session_options[:key]
  end
  
  def get_session_key
    u cookies[get_session_key_name]
  end
  
  def allowed_extensions
    uploadify_options[:allowed_extensions].collect { |ext| "*.#{ext}" }.join(';')
  end
end