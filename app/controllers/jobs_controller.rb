# -*- encoding : utf-8 -*-
class JobsController < BaseController
  require 'open-uri'
  before_filter :authenticate

  def notify
    job_id = params[:job][:id]
    seminar = Seminar.where(:job => job_id).first

    if seminar and seminar.state != 'converted'
      if params[:job][:state] == 'finished'
        output_name = params[:output][:url].split('/').last # Nome criado pelo Zencoder
        seminar.media_content_type = "video/x-flv"
        seminar.media_file_name = output_name
        seminar.media_updated_at = Time.now
        seminar.ready!
        seminar.save!
      elsif params[:job][:state] == 'failed'
        seminar.fail!
      end
    end
  end

  protected

  def authenticate
    authenticate_with_http_basic do |username, password|
      credentials = Redu::Application.config.zencoder_credentials
      username == credentials[:username] && password == credentials[:password]
    end
  end
end
