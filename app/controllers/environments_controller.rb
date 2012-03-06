class EnvironmentsController < BaseController
  load_and_authorize_resource :except => :index, :find_by => :path

  rescue_from CanCan::AccessDenied do |exception|
    flash[:notice] = "Você não tem acesso a essa página"
    redirect_to preview_environment_path(@environment)
  end

  # GET /environments/1
  # GET /environments/1.xml
  def show
    paginating_params = {
      :page => params[:page],
      :order => 'name ASC',
      :limit => 4,
      :per_page => Redu::Application.config.items_per_page
    }

    if can? :manage, @environment
      @courses = @environment.courses.includes(:user_course_associations).
        includes(:spaces).paginate(paginating_params)
    else
      @courses = @environment.courses.includes(:user_course_associations).
        includes(:spaces).published.paginate(paginating_params)
    end

    respond_to do |format|
      format.html
      format.js { render_endless 'courses/item', @courses, '#courses_list' }
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
    @header_environment = @environment.clone :include => [:users,
      :administrators, :teachers, :tutors]
    @header_environment.id = @environment.id

    respond_to do |format|
      format.html { render 'environments/admin/edit' }
    end
  end

  # POST /environments
  # POST /environments.xml
  def create
    case params[:step]
    when "1" # tela de planos
      @environment.valid?
      @step = 2

      respond_to do |format|
        format.html { render :new }
      end
    when "2" # tela dos forms
      @environment.valid?
      @plan = Plan.from_preset(params[:plan].to_sym)
      @plan = params[:plan] if @plan.valid?

      @step = 3

      respond_to do |format|
        format.html { render :new }
      end
    when "3" # tela de informações
      respond_to do |format|
        @plan = Plan.from_preset(params[:plan].to_sym)
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
        @plan = Plan.from_preset(params[:plan].to_sym)
        @plan.user = current_user
        @environment.courses.first.plans << @plan
        @environment.owner = current_user
        @environment.courses.first.owner = current_user
        if @environment.save && @plan.save
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
    @header_environment = @environment.clone :include => [:users,
      :administrators, :teachers, :tutors]
    @header_environment.id = @environment.id

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

    paginating_params = {
      :page => params[:page],
      :order => 'name ASC',
      :per_page => Redu::Application.config.items_per_page
    }

    @courses = @environment.courses.includes(:user_course_associations).
      includes(:spaces).published.paginate(paginating_params)

    respond_to do |format|
      format.html
      format.js { render_endless 'courses/item', @courses, '#courses_list' }
      format.xml  { render :xml => @environment }
    end
  end

  def admin_courses
    @environment = Environment.find(params[:id])
    @courses = @environment.courses.paginate(:page => params[:page],
                                             :per_page => Redu::Application.config.items_per_page)

    respond_to do |format|
      format.html { render "environments/admin/admin_courses" }
      format.js do
        render_endless 'courses/admin/item_admin', @courses, '#course_list'
      end
    end
  end

  def admin_members
    @memberships = UserEnvironmentAssociation.of_environment(@environment).
      paginate(
        :include => [{ :user => {:user_course_associations => { :course => :environment }} }],
        :page => params[:page],
        :order => 'updated_at DESC',
        :per_page => Redu::Application.config.items_per_page)

    respond_to do |format|
      format.html { render "environments/admin/admin_members" }
      format.js do
        render_endless 'environments/admin/user_item_admin', @memberships,
          '#user_list_table'
      end
    end
  end

  # Remove um ou mais usuários de um Environment destruindo todos os relacionamentos
  # entre usuário e os níveis mais baixos da hierarquia.
  def destroy_members
    # Course.id do environment
    courses = @environment.courses
    # Spaces do environment (unidimensional)
    spaces = courses.collect{ |c| c.spaces }.flatten
    users_ids = []
    users_ids = params[:users].collect{|u| u.to_i} if params[:users]

    unless users_ids.empty?
      User.with_ids(users_ids).includes(:user_environment_associations,
                             :user_course_associations,
                             :user_space_associations).each do |user|

        user.spaces.delete(spaces)
        user.courses.delete(courses)
        user.environments.delete(@environment)
      end
      flash[:notice] = "Os usuários foram removidos do ambiente #{@environment.name}"
    end

    respond_to do |format|
      format.html { redirect_to :action => :admin_members }
    end
  end

  def search_users_admin
    roles = []
    roles = params[:role_filter].collect {|r| r.to_i} if params[:role_filter]
    keyword = []
    keyword = params[:search_user] || nil

    @memberships = UserEnvironmentAssociation.with_roles(roles).
                   of_environment(@environment).with_keyword(keyword).
                   includes(:user => [{ :user_course_associations => :course }]).
                   paginate(:page => params[:page],
                    :order => 'user_environment_associations.updated_at DESC',
                    :per_page => Redu::Application.config.items_per_page)

    respond_to do |format|
      format.js { render "environments/admin/search_users_admin" }
    end
  end
end
