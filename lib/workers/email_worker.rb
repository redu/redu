# Now using ar_mailer

=begin
class EmailWorker < BackgrounDRb::MetaWorker
  set_worker_name :email_worker
  
  def create(args = nil)
    # this method is called, when worker is loaded for the first time
    
    # Initializing smtp server
    self.start_smtp
  end
  
  def send_message(email)
    # restarting SMTP connection if needed
    unless smtp_started?
      logger.info "#{Time.now} restarting SMTP"
      smtp_restart
    end
    
    destinations = email.destinations
    email.ready_to_send
    sender = (email['return-path'] && email['return-path'].spec) || email['from']
    
    logger.info "#{Time.now}\nscheduling email %s -> %s" % [sender, destinations]
    
    begin
      res = @smtp.send_message email.encoded, sender, destinations
      logger.info "#{Time.now}\nsent email %011d from %s to %s: %p" %
            [job_key, sender, destinations, res]
      persistent_job.finish!
    rescue Net::SMTPFatalError => e
      logger.info "#{Time.now}\n5xx error sending email %d:\n\t%s" %
            [job_key, e.backtrace.join("\n\t")]
    rescue Net::SMTPServerBusy => e
      smtp_restart
      persistent_job.release_job
      logger.info "#{Time.now}\nserver too busy, trying to restart the connection and enqueueing again"
    rescue Net::SMTPUnknownError, Net::SMTPSyntaxError, TimeoutError, Timeout::Error => e
      loggger.info "#{Time.now}\nerror sending email %d:\n\t%s" %
            [job_key, e.class, e.backtrace.join("\n\t")]
      persistent_job.release_job
    end    
  end
  
  protected

  # Proxy to ActionMailer::Base::smtp_settings.
  def smtp_settings
    ActionMailer::Base.smtp_settings rescue ActionMailer::Base.server_settings
  end
  
  # Starts a new SMTP server
  def start_smtp
    require 'net/smtp'
    
    @smtp.finish if @smtp 
    
    logger.info "# #{Time.now}\nOpening SMTP connection on port #{smtp_settings[:port]}"
    settings = [
      smtp_settings[:domain],
      (smtp_setdelaytings[:user] || smtp_settings[:user_name]),
      smtp_settings[:password],
      smtp_settings[:authentication]
    ]
    
    @smtp = Net::SMTP.new(smtp_settings[:address], smtp_settings[:port])
    if @smtp.respond_to?(:enable_starttls_auto)
      @smtp.enable_starttls_auto unless smtp_settings[:tls] == false
    else
      settings << smtp_settings[:tls]
    end
    
    begin
      @smtp.start(*settings)
      logger.info "#{Time.now}\nSMTP connection started" if smtp_started?
    rescue Net::SMTPAuthenticationError => e
      @failed_auth_count += 1
      if @failed_auth_count >= MAX_AUTH_FAILURES then
        logger.info "#{Time.now}\nauthentication error, giving up."
        raise e
      else
        logger.info "#{Time.now}\nauthentication error, retrying."
      end
    rescue Net::SMTPServerBusy, SystemCallError, OpenSSL::SSL::SSLError, Net::SMTPFatalError, Net::SMTPUnknownError, Net::SMTPSyntaxError, TimeoutError, IOError => e
        logger.info "#{Time.now}\nother error, giving up."
        raise e
    end
  end
  
  def smtp_started?
    @smtp && @smtp.started?
  end
  
  def smtp_restart
    @smtp.finish
    start_smtp
  end
  
end
=end

