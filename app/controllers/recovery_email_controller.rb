class RecoveryEmailController < ApplicationController
  def create
    @recovery_email = RecoveryEmail.new(params[:recovery_email][:email])
    if @recovery_email.valid?
      # TODO send message here
      flash[:notice] = "Message sent! Thank you for contacting us."
      redirect_to root_url
    else
      render :action => 'new'
  end
end
