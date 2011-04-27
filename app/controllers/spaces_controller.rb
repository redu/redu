class SpacesController < BaseController

  # Necessário pois Space não é nested route de course
  before_filter :find_space_course_environment,
    :except => [:cancel]

  load_and_authorize_resource :environment,
    :except => [:create, :cancel]
  load_and_authorize_resource :course, :through => :environment,
    :except => [:create, :cancel]
  load_and_authorize_resource :space, :through => :course,
    :except => [:create, :cancel]

  after_filter :create_activity, :only => [:create]

  rescue_from CanCan::AccessDenied do |exception|
    flash[:notice] = "Você não tem acesso a essa página"
    redirect_to preview_environment_course_path(@environment, @course)
  end

  def take_ownership
    @space.update_attribute(:owner, current_user)
    flash[:notice] = "Você é o novo dono desta disciplina."
    redirect_to @space
  end

  def vote
    current_user.vote(@space, params[:like])
    respond_to do |format|
      format.js { render :template => 'shared/like.rjs', :locals => { :votes_for => @space.votes_for().to_s} }
    end
  end

  #TODO mudar para admin_look_and_feel (padroes)
  def look_and_feel
  end

  def set_theme
    @space.update_attributes(params[:space])

    flash[:notice] = "Tema modificado com sucesso!"
    redirect_to look_and_feel_space_path
  end

  def manage
  end

  def admin_members
    @memberships = @space.user_space_associations.approved.paginate(:page => params[:page],
                                                   :order => 'updated_at DESC',
                                                   :per_page => AppConfig.items_per_page)

    respond_to do |format|
      format.html
      format.js { render :template => 'shared/admin_members' }
    end
  end

  def admin_bulletins
    paginating_params = {
      :include => :owner,
      :order => 'updated_at ASC',
      :per_page => AppConfig.items_per_page
    }

    if params.has_key?(:page_pending)
      paginating_params[:page] = params[:page_pending]
    else
      paginating_params[:page] = params[:page]
    end

    @pending_bulletins = @space.bulletins.waiting.paginate(paginating_params)
    @bulletins = @space.bulletins.approved.paginate(paginating_params)

    respond_to do |format|
      format.html
      format.js
    end
  end

  def admin_events
    @space = Space.find(params[:id])
    paginating_params = {
      :include => :owner,
      :order => 'updated_at DESC',
      :per_page => AppConfig.items_per_page
    }

    if params.has_key?(:page_pending)
      paginating_params[:page] = params[:page_pending]
    else
      paginating_params[:page] = params[:page]
    end

    @pending_events = @space.events.waiting.paginate(paginating_params)
    @events = @space.events.approved.paginate(paginating_params)

    respond_to do |format|
      format.html
      format.js
    end
  end

  def search_users_admin

    if params[:search_user].empty?
      @memberships = @space.user_space_associations.approved.paginate(:include => :user,
                                                    :page => params[:page],
                                                    :order => 'updated_at DESC',
                                                    :per_page => AppConfig.items_per_page)
    else
      qry = params[:search_user] + '%'
      @memberships =
        @space.user_space_associations.approved.users_by_name(qry).paginate(
                                :page => params[:page],
                                :order => 'user_space_associations.updated_at DESC',
                                :per_page => AppConfig.items_per_page)
    end

    respond_to do |format|
      format.js do
        render :update do |page|
          page.replace_html 'user_list', :partial => 'user_list_admin', :locals => {:memberships => @memberships}
        end
      end
    end
  end

  def moderate_bulletins
    if params[:bulletin]
      approved = params[:bulletin].reject{|k,v| v == 'reject'}
      rejected = params[:bulletin].reject{|k,v| v == 'approve'}

      Bulletin.update_all("state = 'approved'", :id => approved.keys) if approved
      Bulletin.update_all("state = 'rejected'", :id => rejected.keys) if rejected

      flash[:notice] = 'Notícias moderadas!'
    else
      flash[:error] = "Para moderar você precisa escolher entre aprovar ou rejeitar."
    end

    redirect_to admin_bulletins_space_path(@space)
  end

  def moderate_events
    if params[:event]
      approved = params[:event].reject{|k,v| v == 'reject'}
      rejected = params[:event].reject{|k,v| v == 'approve'}

      Event.update_all("state = 'approved'", :id => approved.keys) if approved
      Event.update_all("state = 'rejected'", :id => rejected.keys) if rejected

      flash[:notice] = 'Eventos moderados!'
    else
      flash[:error] = "Para moderar você precisa escolher entre aprovar ou rejeitar."
    end

    redirect_to admin_events_space_path(@space)
  end

  # lista todos os membros da escola
  #TODO mover para user
  def members
    #optei por .users ao inves de .students
    @members =
      @space.user_space_associations.paginate( :page => params[:page],
                                               :order => 'updated_at DESC',
                                               :per_page => 12 )

    @member_type = "membros"

    respond_to do |format|
      format.html {
        render "view_members"
      }
      format.js
      format.xml  { render :xml => @members }
    end
  end

  # lista todos os professores
  #TODO mover para user
  def teachers
    @members = @space.teachers.paginate(
      :page => params[:page],
      :order => 'updated_at DESC',
      :per_page => AppConfig.users_per_page)

    @member_type = "professores"

    respond_to do |format|
      format.html {
        render "view_members"
      }
      format.xml  { render :xml => @members }
    end
  end

  # GET /spaces
  # GET /spaces.xml
  def index
    paginating_params = {
      :page => params[:page],
      :order => (params[:sort]) ? params[:sort] + ' DESC' : 'created_at DESC',
      :per_page => 12
    }

    if params[:user_id] # aulas do usuario
      @user = User.find_by_login(params[:user_id])
      @user = User.find(params[:user_id]) unless @user
      @spaces = @user.spaces.paginate(paginating_params)

    elsif params[:search] # search

      @spaces = Space.name_like_all(params[:search].to_s.split).ascend_by_name.paginate(paginating_params)
    else
      if not @spaces
        params[:audience].nil? ? @spaces = Space.all.paginate(paginating_params) : @spaces = Audience.find(params[:audience]).spaces.paginate(paginating_params)
        @searched_for_all = true
      end
    end
    respond_to do |format|
			#TODO verificar esse @lecture, saber o por quê de ser chamado
      # format.xml  { render :xml => @lectures }
      format.html do
        if @user
          redirect_to @user
        end
      end
      format.js  do
        if @user
          render :update do |page|
            page.replace_html  'tabs-4-content', :partial => 'user_spaces'
          end
        end
      end
    end
  end

  # GET /spaces/1
  # GET /spaces/1.xml
  def show
    if @space and @space.removed
      redirect_to removed_page_path and return
    end

    if @space
      @statuses = @space.recent_activity(params[:page])
      @statusable = @space
    end

    respond_to do |format|
      if @space
        @status = Status.new

        format.html
        format.js
        format.xml  { render :xml => @space }
      else
        format.html {
          flash[:error] = "A disciplina \"" + params[:id] + "\" não existe ou não está cadastrada no Redu."
          redirect_to spaces_path
        }
      end
    end
  end

  def cancel
    @course = Course.find(params[:course_id])
    redirect_to(environment_course_path(@course.environment, @course))
  end

  # GET /spaces/new
  # GET /spaces/new.xml
  def new
    @space = Space.new(params[:space])
    @course = Course.find(params[:course_id])
    authorize! :manage, @course
    @environment = @course.environment

    respond_to do |format|
      format.html
    end
  end

  # GET /spaces/1/edit
  def edit
    @header_space = @space.clone

    respond_to do |format|
      format.html
    end
  end

  # POST /spaces
  # POST /spaces.xml
  def create
    @space = Space.new(params[:space])
    @space.course = @course
    authorize! :manage, @course
    @environment = @course.environment
    @space.owner = current_user
    # FIXME o submission_type deve ser escolhido pela interface, por
    # enquanto todos tem a permissão de postar
    @space.submission_type = '3'

    if @space.valid?
      @space.save
    end

    respond_to do |format|
      if @space.new_record?
        format.html do
          render :template => 'spaces/new'
        end
      else
        format.html do
          flash[:notice] = "Disciplina criada!"
          redirect_to environment_course_path(@environment, @course)
        end
      end
    end
  end

  # PUT /spaces/1
  # PUT /spaces/1.xml
  def update
    @header_space = @space.clone

    respond_to do |format|
      if @space.update_attributes(params[:space])
        if params[:space][:subscription_type].eql? "1" # Entrada de membros passou a ser livre, aprovar todos os membros pendentes
          UserSpaceAssociation.update_all("status = 'approved'", ["space_id = ? AND status = 'pending'", @space.id])
        end
        flash[:notice] = 'A disciplina foi atualizada com sucesso!'
        format.html { redirect_to(@space) }
        format.xml  { head :ok }
      else
        format.html do
          render :template => 'spaces/edit'
        end
        format.xml  { render :xml => @space.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /spaces/1
  # DELETE /spaces/1.xml
  def destroy
    @space.destroy

    respond_to do |format|
      format.html { redirect_to(environment_course_path(@space.course.environment, @space.course)) }
      format.xml  { head :ok }
    end
  end

  def publish

    @space.publish!

    flash[:notice] = "O space #{@space.name} foi publicado."
    redirect_to space_path(@space)
  end

  def unpublish
    @space.unpublish!
    flash[:notice] = "O space #{@space.name} foi despublicado."
    redirect_to space_path(@space)
  end

  # Listagem de usuários do Space
  def users
    @users = @space.users.
      paginate(:page => params[:page], :order => 'first_name ASC', :per_page => 18)

    respond_to do |format|
      format.html
      format.js
    end
  end

  protected

  def find_space_course_environment
    if params.has_key?(:id)
      @space = Space.find(params[:id])
    end
    # No SpaceController#new o course_id é passado como param
    @course = @space.nil? ? Course.find(params[:course_id]) : @space.course
    @environment = @course.environment
  end

  def can_be_owner_required
    current_user.can_be_owner?(@space) ? true : access_denied
  end

  def is_not_member_required
    if current_user.get_association_with(@space)
      redirect_to space_path(@space)
    end
  end
end
