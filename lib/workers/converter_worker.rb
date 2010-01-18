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
    thumb = File.join(File.dirname(resource.media.path), "#{ resource.id }")
    # Conversion command
    `ffmpeg -i #{ resource.media.path } -ar 22050 -ab 32 -s 480x360 -vcodec flv -r 25 -qscale 8 -f flv -y #{ file }`
    # Thumbnails
    `ffmpeg -i #{ resource.media.path } -ss 00:00:03 -t 00:00:01 -vcodec mjpeg -vframes 1 -an -f rawvideo -s 480x360 #{ thumb }480x360.jpg`
    `ffmpeg -i #{ resource.media.path } -ss 00:00:03 -t 00:00:01 -vcodec mjpeg -vframes 1 -an -f rawvideo -s 128x96 #{ thumb }128x96.jpg`
    $?.exitstatus == 0
  end
end

