class ContactsController < BaseController
  def new
    @contact = Contact.new

    respond_to do |format|
      format.html { render :layout => 'clean' }
    end
  end

  def create
    @contact = Contact.create(params[:contact])
    if @contact.valid?
      if @contact.about_an_error?
        @contact.body << "\n\n Stacktrace: \n"
        @contact.body << `tail -n 1500 #{Redu::Application.root}/log/#{Rails.env}.log | grep -C 300 "Completed 500"`
      end

      @contact.deliver
      @boxed = true # CSS style
      unless request.xhr?
        flash[:notice] = \
          'Seu e-mail foi enviado, aguarde o nosso contato. Obrigado!'
      end
    end

    respond_to do |format|
      format.js
    end
  end
end
