# -*- encoding : utf-8 -*-
class EnvironmentsController < BaseController
  load_and_authorize_resource :except => :index, :find_by => :path

  rescue_from CanCan::AccessDenied do |exception|
    session[:return_to] = request.fullpath

    if @environment
      if @environment.blocked?
        flash[:error] = "Entre em contato com o administrador deste ambiente."
      elsif current_user.nil?
        flash[:info] = "Essa área só pode ser vista após você acessar o Redu com seu nome e senha."
      else
        flash[:info] = "Você não tem acesso a essa página"
      end

      redirect_to preview_environment_path(@environment)
    else
      flash[:error] = "Essa área só pode ser vista após você acessar o Redu com seu nome e senha."
      redirect_to application_path
    end
  end

  # GET /environments/1
  # GET /environments/1.xml
  def show
    @courses = @environment.courses.includes(:environment, :tags)

    unless can? :manage, @environment
      @courses = @courses.published
    end

    @courses = @courses.order('name ASC').page(params[:page]).
      per(Redu::Application.config.items_per_page)

    respond_to do |format|
      format.html { render layout: 'environments/show' }
      format.xml  { render :xml => @environment }
    end
  end

  # GET /environments/new
  # GET /environments/new.xml
  def new
    respond_to do |format|
      format.html
      format.xml { render :xml => @environment }
    end
  end

  # GET /environments/1/edit
  def edit
    respond_to do |format|
      format.html { render 'environments/admin/edit', layout: 'environments/admin' }
    end
  end

  # POST /environments
  # POST /environments.xml
  def create
    case params[:step]
    when "1" # tela de planos
      @step = 2

      respond_to do |format|
        format.html { render :new }
      end
    when "2" # tela dos forms
      @plan = Plan.from_preset(params[:plan].to_sym)
      @plan.user = current_user
      @plan = params[:plan] if @plan.valid?

      @step = 3

      respond_to do |format|
        format.html { render :new }
      end
    when "3" # tela de informações
      respond_to do |format|
        @plan = Plan.from_preset(params[:plan].to_sym)
        @plan.user = current_user
        @plan_humanize = @plan.clone
        @plan = params[:plan] if @plan.valid?

        if @environment.valid?
          @step = 4

          format.html { render :new }
        else
          @step = 3

          format.html { render :new }
        end
      end
    when "4"

      respond_to do |format|
        @environment.owner = current_user
        @environment.courses.first.owner = current_user

        @plan = Plan.from_preset(params[:plan].to_sym)
        @plan.user = current_user

        if @environment.save && @plan.valid?
          @environment.courses.first.plan = @plan

          @environment.courses.first.create_quota
          if @plan.create_invoice_and_setup
            format.js { render :pay }
            format.html do
              redirect_to confirm_plan_path(@plan)
            end
          else
            format.html do
              flash[:notice] = "Parabens, o seu ambiente de ensino foi criado"
            end
            format.js do
              render :redirect
            end
          end
        else
          format.js { render :new }
          format.html { render :new }
          format.xml  { render :xml => @environment.errors,
            :status => :unprocessable_entity }
        end
      end
    end
  end

  # PUT /environments/1
  # PUT /environments/1.xml
  def update
    @header_environment = @environment.clone

    respond_to do |format|
      if @environment.update_attributes(params[:environment])
        flash[:notice] = 'Ambiente atualizado com sucesso.'
        format.html { redirect_to(@environment) }
        format.xml  { head :ok }
      else
        format.html { render 'environments/admin/edit' }
        format.xml  { render :xml => @environment.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /environments/1
  # DELETE /environments/1.xml
  def destroy
    @environment.audit_billable_and_destroy

    respond_to do |format|
      format.html { redirect_to(teach_index_url) }
      format.xml  { head :ok }
    end
  end

  # Visão do Environment para usuários não-membros.
  # TODO Remover quando colocar as permissões, apenas redirecionar no show.
  def preview
    if (can? :read, @environment) && (!can? :manage, @environment)
      redirect_to environment_path(@environment) and return
    end

    @courses = @environment.courses.includes(:user_course_associations).
      includes(:spaces).published.order('name ASC').page(params[:page]).
      per(Redu::Application.config.items_per_page)

    respond_to do |format|
      format.html { render 'show', layout: 'environments/show' }
      format.xml  { render :xml => @environment }
    end
  end

  def admin_courses
    @total_courses = @environment.courses.count
    @courses = @environment.courses.page(params[:page]).
      per(Redu::Application.config.items_per_page)

    respond_to do |format|
      format.html { render 'environments/admin/admin_courses',
                           layout: 'environments/admin' }
    end
  end

  def admin_members
    @memberships = @environment.user_environment_associations.includes(:user).
      order('updated_at DESC').page(params[:page]).
      per(Redu::Application.config.items_per_page)

    respond_to do |format|
      format.html { render 'environments/admin/admin_members',
                           layout: 'environments/admin' }
    end
  end

  # Remove um ou mais usuários de um Environment destruindo todos os relacionamentos
  # entre usuário e os níveis mais baixos da hierarquia.
  def destroy_members
    users_ids = []
    users_ids = params[:users].collect{|u| u.to_i} if params[:users]

    unless users_ids.empty?
      users = User.with_ids(users_ids).includes(:user_course_associations)
      @environment.remove_users(users)

      flash[:notice] = "Os usuários foram removidos do ambiente #{@environment.name}"
    end

    respond_to do |format|
      format.html { redirect_to :action => :admin_members }
    end
  end

  def search_users_admin
    roles = []
    roles = params[:role_filter].collect {|r| r.to_s} if params[:role_filter]
    keyword = []
    keyword = params[:search_user] || nil

    @memberships = UserEnvironmentAssociation.with_roles(roles).
                   of_environment(@environment).with_keyword(keyword).
                   includes(:user => [{ :user_course_associations => :course }]).
                   order('user_environment_associations.updated_at DESC').
                   page(params[:page]).per(Redu::Application.config.items_per_page)

    respond_to do |format|
      format.js { render "environments/admin/search_users_admin" }
    end
  end

  def index
    if params.has_key?(:user_id)
      @user = User.find(params[:user_id])
      view_path = 'users/environments/index'
    else
      @user = current_user
      view_path = 'environments/index'
    end

    authorize! :manage, @user

    @total_environments = @user.environments.count
    @environments = @user.environments.
      includes(:courses => :spaces).page(params[:page]).
      per(Redu::Application.config.items_per_page)

    respond_to do |format|
      format.html do
        render view_path, :layout => 'new_application'
      end
      format.js do
        render_endless('users/environments/environment', @environments,
                       '#my-environments',
                       { :template => 'shared/new_endless_kaminari',
                         :partial_locals => { :user => @user } })
      end
    end
  end

  def admin_plans
    # TODO: Back-end.
    @screen = :lots
    case @screen
    when :empty
      # Exemplo de faturas vazia.
      @licenses = [
        { course: { name: "Curso Lorem Ipsum Sit Dolor",
                    link: "http://www.google.com",
                    type: :public,
                    storage: 0,
                    quota: {
                      space: "0 MB",
                      documents: "0 MB",
                      videos: "0 MB"
                    },
                    licenses: 0 }
        }]
      @licences_in_use = 0
    when :first
      # Exemplo de primeira fatura.
      @licenses = [
        { course: {
            name: "Curso Lorem Ipsum Sit Dolor 2",
            link: "http://www.google.com.br",
            type: :private,
            storage: 80,
            quota: {
              space: "800 MB",
              documents: "400 MB",
              videos: "400 MB"
            },
            licenses: 20 }
        }]
      @licences_in_use = 20
      @invoices = [
        {
          begin: "02/04/2013",
          end: "01/05/2013",
          state: "Em uso",
          total: 0
        }
      ]
    when :to_pay
      # Exemplo de fatura a pagar.
      @licenses = [
        { course: {
            name: "Curso Lorem Ipsum Sit Dolor 2",
            link: "http://www.google.com.br",
            type: :private,
            storage: 80,
            quota: {
              space: "800 MB",
              documents: "400 MB",
              videos: "400 MB"
            },
            licenses: 4 }
        }]
      @licences_in_use = 4
      @invoices = [
        {
          begin: "02/04/2013",
          end: "01/05/2013",
          state: "Em uso",
          total: 0
        },
        {
          begin: "02/03/2013",
          end: "01/04/2013",
          state: "A pagar",
          total: 12
        }
      ]
    when :lots
      # Exemplo de várias faturas.
      @licenses = [
        { course: {
            name: "Curso Lorem Ipsum Sit Dolor 3",
            link: "http://www.google.com.br",
            type: :private,
            storage: 100,
            quota: {
              space: "1000 MB",
              documents: "500 MB",
              videos: "500 MB"
            },
            licenses: 15 }
        },
        { course: {
            name: "Curso Lorem Ipsum Sit Dolor 4",
            link: "http://www.google.com.br",
            type: :private,
            storage: 50,
            quota: {
              space: "400 MB",
              documents: "200 MB",
              videos: "200 MB"
            },
            licenses: 10 }
        },
        { course: {
            name: "Curso Lorem Ipsum Sit Dolor 5",
            link: "http://www.google.com.br",
            type: :public,
            storage: 80,
            quota: {
              space: "800 MB",
              documents: "400 MB",
              videos: "400 MB"
            },
            licenses: 0 }
        }]
      @licences_in_use = 15 + 10
      @invoices = [
        {
          begin: "02/04/2013",
          end: "01/05/2013",
          state: "Em uso",
          total: 0
        },
        {
          begin: "02/03/2013",
          end: "01/04/2013",
          state: "Pago",
          total: 12
        },
        {
          begin: "02/02/2013",
          end: "01/03/2013",
          state: "Pago",
          total: 12
        },
        {
          begin: "02/01/2013",
          end: "01/02/2013",
          state: "Pago",
          total: 12
        }
      ]
    end

    respond_to do |format|
      format.html { render 'environments/admin/admin_plans',
                           layout: 'environments/admin' }
    end
  end
end
