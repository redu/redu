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
    note = params[:note]
    knumber.times { BetaKey.create(:note => note) }

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
    note = params[:note]
    emails = email_addresses.split(",").collect{|email| email.strip }.uniq

    emails.each do |email|
      beta_key = BetaKey.create(:email => email, :note => note)
      UserNotifier.deliver_beta_invitation(email, beta_key.key)
    end

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