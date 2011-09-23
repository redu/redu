class BaseController < ApplicationController
  layout :choose_layout, :except => [:site_index]
  # Work around (ver método self.login_required_base)

  rescue_from CanCan::AccessDenied, :with => :deny_access

  caches_action :site_index, :if => Proc.new{|c| c.cache_action? }
  def cache_action?
    !logged_in? && controller_name.eql?('base') && params[:format].blank?
  end

  def removed_item
    @type = params[:type]
  end

  def tos
    #TODO
  end

  def privacy
    #TODO
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
    respond_to do |format|
      format.html do
        if current_user
          redirect_to home_user_path(current_user) and return
        end
          render :layout => 'clean'
      end
    end
  end

  def homepage_features
    @homepage_features = HomepageFeature.find_features
    @homepage_features.shift
    render :partial => 'homepage_feature', :collection => @homepage_features and return
  end

  def admin_required
    current_user && current_user.admin? ? true : (raise CanCan::AccessDenied)
  end

  def space_admin_required(space_id)
    (current_user && current_user.space_admin?(space_id) || Space.find(space_id).owner == current_user) ? true : access_denied
  end

  def find_user
    # if @user = User.active.find(params[:user_id] || params[:id])
    if @user = User.find(params[:user_id] || params[:id])
      @is_current_user = (@user && @user.eql?(current_user))
      unless logged_in? || @user.profile_public?
        flash[:error] = t :this_users_profile_is_not_public_youll_need_to_create_an_account_and_log_in_to_access_it
        redirect_to :controller => 'sessions', :action => 'new'
      end
      return @user
    else
      flash[:error] = t :please_log_in
      redirect_to :controller => 'sessions', :action => 'new'
      return false
    end
  end

  def require_current_user
    @user ||= User.find(params[:user_id] || params[:id] )
    unless admin? || (@user && (@user.eql?(current_user)))
      redirect_to :controller => 'sessions', :action => 'new' and return false
    end
    return @user
  end

  def contact
    if request.get?
      @contact = Contact.new
    else
      #TODO Criar initialize para deixar essa parte menos nojenta
      @contact = Contact.new
      @contact.name = params[:contact][:name]
      @contact.email = params[:contact][:email]
      @contact.kind = params[:contact][:kind]
      @contact.subject = params[:contact][:subject]
      @contact.body = params[:contact][:body]
      if @contact.valid?
        @contact.deliver
        flash[:notice] = "Seu e-mail foi enviado, aguarde o nosso contato. Obrigado."
        redirect_to contact_path
      else
        render :action => :contact, :method => :get
      end
    end
  end

  protected

  # Mostra ou não o layout com base na presença do header x-pjax
  def choose_layout
    return request.headers['X-PJAX'].nil? ?  'application' : false
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
  def render_endless(partial, collection, selector,
                     partial_locals={},  paginate_opts={})
    locals = {
      :partial => partial, # Partial do itens a serem renderizados
      :collection => collection, # Coleção em questão
      :selector => selector, # Seletor do HTML que receberá os itens
      :partial_locals => partial_locals, # Locals necessários no partial do item
      :paginate_opts => paginate_opts # Options para o will_paginate
    }
      render :template => 'shared/endless', :locals => locals
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
