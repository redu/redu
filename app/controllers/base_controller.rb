class BaseController < ApplicationController
  layout :choose_layout, :except => [:landing]
  # Work around (ver método self.login_required_base)

  rescue_from CanCan::AccessDenied, :with => :deny_access

  def tos
    render :layout => 'clean'
  end

  def privacy
    render :layout => 'clean'
  end

  def teach_index
    authorize! :teach_index, :base

    respond_to do |format|
      format.html
    end
  end

  def site_index
    # FIXME verificar se causa algum prejuízo na performance, ou só criar a sessão se o current_user for nil
    @user_session = UserSession.new
    @user = User.new

    respond_to do |format|
      format.html do
        if current_user
          redirect_to home_user_path(current_user) and return
        end
        render :layout => 'landing'
      end
    end
  end

  def contact
    if request.get?
      @contact = Contact.new
    else
      @contact = Contact.create(params[:contact])
      if @contact.valid?
        if @contact.about_an_error?
          @contact.body << "\n\n Stacktrace: \n"
          @contact.body << `tail -n 1500 #{Redu::Application.root}/log/#{Rails.env}.log | grep -C 300 "Completed 500"`
        end

        @contact.deliver
        @boxed = true # CSS style
        flash[:notice] = 'Seu e-mail foi enviado, aguarde o nosso contato. Obrigado!' unless request.xhr?
      end
    end
    respond_to do |format|
      format.html { render :layout => 'clean' }
      format.js
    end
  end

  def about
    redirect_to "http://tech.redu.com.br"
  end

  protected

  # Mostra ou não o layout com base na presença do header x-pjax
  def choose_layout
    return request.headers['X-PJAX'].nil? ?  'application' : 'pjax'
  end

  def logged_in?
    !current_user.nil?
  end

  # Workaround para o bug #55 (before_filter não funciona no filter chain)
  # http://railsapi.com/doc/rails-v2.3.8/classes/ActionController/Filters/ClassMethods.html
  def login_required_base
    login_required
  end

  # Renderiza a resposta do endless de acordo com os parâmetros passados
  def render_endless(partial, collection, selector, opts={})

    template = opts[:template] || 'shared/endless'

    locals = {
      :partial => partial, # Partial do itens a serem renderizados
      :collection => collection, # Coleção em questão
      :selector => selector, # Seletor do HTML que receberá os itens
      # Locals necessários no partial do item
      :partial_locals => opts[:partial_locals] || {},
      :paginate_opts => opts[:paginate_opts] || {} # Options para o will_paginate
    }

    render :template => template, :locals => locals
  end

  # Renderiza a resposta do endless de acordo com os parâmetros passados
  def render_sidebar_endless(partial, collection, selector, text, html_class=nil,
                             partial_locals={})
    locals = {
      :partial => partial, # Partial do itens a serem renderizados
      :collection => collection, # Coleção em questão
      :selector => selector, # Seletor do HTML que receberá os itens
      :html_class => html_class, # Classe customizada do endless
      :text => text, # Texto que aparece abaixo do endless
      :partial_locals => partial_locals # Locals necessários no partial do item
    }
      render :template => 'shared/sidebar_endless', :locals => locals
  end

  def deny_access(exception)
    flash[:notice] = "Você não tem acesso a essa página."
    redirect_to home_path
  end
end
