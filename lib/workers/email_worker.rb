

class EmailWorker < BackgrounDRb::MetaWorker
  set_worker_name :email_worker
  
  def create(args = nil)
    # this method is called, when worker is loaded for the first time
    
    # Initializing smtp server
    self.start_smtp
  end
  
  def send_message(email)
    # restarting SMTP connection if needed
    start_smtp unless smtp_started?
    
    destinations = email.destinations
    email.ready_to_send
    sender = (email['return-path'] && email['return-path'].spec) || email['from']
    
    logger.info "scheduling email %s -> %s" % [sender, destinations]
    
    begin
      res = @smtp.send_message email.encoded, sender, destinations
      logger.info "sent email %011d from %s to %s: %p" %
            [job_key, sender, destinations, res]
    rescue Net::SMTPFatalError => e
      logger.info "5xx error sending email %d:\n\t%s" %
            [job_key, e.backtrace.join("\n\t")]
    rescue Net::SMTPServerBusy => e
      smtp_restart
      MiddleMan.worker(:email_worker).enq(email)
      logger.info "server too busy, trying to restart the connection and enqueueing again"
    rescue Net::SMTPUnknownError, Net::SMTPSyntaxError, TimeoutError, Timeout::Error => e
      loggger.info "error sending email %d: %p(%s):\n\t%s" %
            [job_key, email.encoded, e.class, e.backtrace.join("\n\t")]
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
    logger.info "Opening SMTP connection on port #{smtp_settings[:port]}"
    settings = [
      smtp_settings[:domain],
      (smtp_settings[:user] || smtp_settings[:user_name]),
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
      logger.info "SMTP connection started" if smtp_started?
    rescue Net::SMTPAuthenticationError => e
      @failed_auth_count += 1
      if @failed_auth_count >= MAX_AUTH_FAILURES then
        logger.info "authentication error, giving up: #{email[:message]}"
        raise e
      else
        logger.info "authentication error, retrying: #{email[:message]}"
      end
    rescue Net::SMTPServerBusy, SystemCallError, OpenSSL::SSL::SSLError
      # ignore SMTPServerBusy/EPIPE/ECONNRESET from Net::SMTP.start's ensure
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

