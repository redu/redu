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
      beta_key = BetaKey.create(:email => email, :note => note, :last_sent_at => Time.now)
      UserNotifier.deliver_beta_invitation(email, beta_key.key)
    end

    respond_to do |format|
      flash[:notice] = "Convites enviados!"
      format.html { redirect_to(beta_keys_url) }
      format.xml  { head :ok }
    end
  end

  # Agenda novo envio de chave (se ela foi atribuida a um e-mail)
  def resend_key
    beta_key = BetaKey.find(params[:id])

    if beta_key and beta_key.email
      UserNotifier.deliver_beta_invitation(beta_key.email, beta_key.key)
      beta_key.update_attribute('last_sent_at', Time.now)
      #TODO adicionar atributo que mostra a quantidade de envios

      respond_to do |format|
        format.html {
          flash[:notice] = "Convites reenviados!"
          redirect_to(beta_keys_url)
        }

        format.js {
          render :update do |page|
          page << "$('#key-#{beta_key.id} td.resend span').remove()"
          page << "$('#key-#{beta_key.id} td.resend').append(\"<span class='sucess loud'>Ok</span>\")"
          page << "$('#key-#{beta_key.id} td.last_sent').html(\"#{time_ago_in_words(beta_key.last_sent_at)}\")"
          end
        }
      end
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
