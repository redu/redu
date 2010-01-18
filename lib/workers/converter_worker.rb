class ConverterWorker < BackgrounDRb::MetaWorker
  set_worker_name :converter_worker
  def create(args = nil)
    # this method is called, when worker is loaded for the first time
    
  end
  
  def convert(resource_id)
    resource = Resource.find(resource_id)
    
    success = self.convert_command(resource)
    
    if success
	    resource.converted!
	  else
	    resource.failure!
    end  
    
 		persistent_job.finish!
 		
  end
  
  protected
  
  def convert_command(resource)
    file = File.join(File.dirname(resource.media.path), "#{resource.id}.flv") #TODO make converted file path a constant.
    
    # Conversion command
    `ffmpeg -i #{ resource.media.path } -ar 22050 -ab 32 -s 480x360 -vcodec flv -r 25 -qscale 8 -f flv -y #{ file }`
    
    $?.exitstatus == 0
  end
end

