class JobsController < BaseController
  require 'open-uri'  
  before_filter :authenticate
  
  def notify
    job_id = params[:job][:id]
    seminar = Seminar.find(:first, :conditions => ["job = ?", job_id])
    
    if seminar
      if params[:job][:state] == 'finished'
        output_name = params[:output][:url].split('/').last # Nome criado pelo Zencoder
        seminar.media_content_type = "video/x-flv"
        seminar.media_file_name = output_name
        seminar.media_updated_at = Time.now
        seminar.save!
      elsif params[:job][:state] == 'failed'
        seminar.fail!
      end
    end
  end
  
  protected

  def authenticate
    authenticate_or_request_with_http_basic do |username, password|
      username == ZENCODER_CREDENTIALS[:username] && password == ZENCODER_CREDENTIALS[:password]
    end
  end
end
