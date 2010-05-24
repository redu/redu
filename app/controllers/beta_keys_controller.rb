class BetaKeysController < BaseController
  
  
  # GET /access_keys
  # GET /access_keys.xml
  def index
      @beta_keys = BetaKey.find(:all)
  
    respond_to do |format|
      format.html # index.html.erb
    end
  end
  

  # POST /access_keys
  # POST /access_keys.xml
  def generate
    
    knumber = params[:number].to_i
    knumber.times { BetaKey.create()  }  
    

    respond_to do |format|
        flash[:notice] = knumber.to_s + ' chaves geradas!'
        format.html { redirect_to(beta_keys_path) }
    end
  end

  
  def print_blank
    @beta_keys = BetaKey.find(:all, :conditions => ["email IS NULL AND user_id IS NULL"])
    render "print_blank", :layout => false
    
  end
  
  def invite
    email_addresses = params[:emails]
    
=begin validacao    
    invalid_emails = []
    email_addresses = email_addresses || ''
    emails = email_addresses.split(",").collect{|email| email.strip }.uniq
    
    emails.each{ |email|
      unless email =~ /[\w._%-]+@[\w.-]+.[a-zA-Z]{2,4}/
        invalid_emails << email
      end        
    }
    unless invalid_emails.empty?
      record.errors.add(:email_addresses, " included invalid addresses: <ul>"+invalid_emails.collect{|email| '<li>'+email+'</li>' }.join+"</ul>")
      record.email_addresses = (emails - invalid_emails).join(', ')
    end
=end    
    
    emails = email_addresses.split(",").collect{|email| email.strip }.uniq 
    emails.each{|email|
      
      beta_key = BetaKey.create(:email => email)
    
      UserNotifier.deliver_beta_invitation(email, beta_key.key)
    }
    
    respond_to do |format|
      flash[:notice] = "Convites enviados!"
      format.html { redirect_to(beta_keys_url) }
      format.xml  { head :ok }
    end
    
    
  end
  

  # DELETE /access_keys/1
  # DELETE /access_keys/1.xml
  def destroy
    @beta_key = BetaKey.find(params[:id])
    @beta_key.destroy

    respond_to do |format|
      format.html { redirect_to(beta_keys_url) }
      format.xml  { head :ok }
    end
  end
  
    # DELETE /access_keys/1
  # DELETE /access_keys/1.xml
  def remove_all
    @beta_key = BetaKey.delete_all

    respond_to do |format|
      format.html { redirect_to(beta_keys_url) }
      format.xml  { head :ok }
    end
  end
  
 
  
  
end
