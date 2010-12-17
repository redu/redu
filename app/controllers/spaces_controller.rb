class SpacesController < BaseController
  layout 'environment'

  # Necessário pois Space não é nested route de course
  before_filter :find_space_course_environment,
    :except => [:create, :cancel]

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
    flash[:notice] = "Você é o novo dono deste espaço!"
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
    @memberships = UserSpaceAssociation.paginate(:conditions => ["status like 'approved' AND space_id = ?", @space.id],
                                                  :include => :user,
                                                  :page => params[:page],
                                                  :order => 'updated_at DESC',
                                                  :per_page => AppConfig.items_per_page)
    respond_to do |format|
      format.html
    end
  end

  def admin_bulletins
    @pending_bulletins = Bulletin.paginate(:conditions => ["bulletinable_type LIKE 'Space'
                                   AND bulletinable_id = ?
                                   AND state LIKE ?", @space.id, "waiting"],
                                   :include => :owner,
                                   :page => params[:page],
                                   :order => 'updated_at ASC',
                                   :per_page => 20)

    @bulletins = Bulletin.paginate(:conditions => ["bulletinable_type LIKE 'Space'
                                   AND bulletinable_id = ?
                                   AND state LIKE ?", @space.id, "approved"],
                                   :include => :owner,
                                   :page => params[:page],
                                   :order => 'updated_at ASC',
                                   :per_page => 20)
    respond_to do |format|
      format.html
    end
  end

  def admin_events
    @space = Space.find(params[:id])
    @pending_events = Event.paginate(:conditions => ["eventable_id = ?" \
                                     " AND eventable_type LIKE 'Space'" \
                                     " AND state LIKE ?", @space.id, "waiting"],
                                     :include => :owner,
                                     :page => params[:page],
                                     :order => 'updated_at ASC',
                                     :per_page => 20)

     @events = Event.paginate(:conditions => ["eventable_id = ?" \
                             " AND eventable_type LIKE 'Space'" \
                             " AND state LIKE ?", @space.id, "approved"],
                             :include => :owner,
                             :page => params[:page],
                             :order => 'updated_at ASC',
                             :per_page => 20)

     respond_to do |format|
      format.html
     end
  end

  def search_users_admin

    if params[:search_user].empty?
      @memberships = UserSpaceAssociation.paginate(:conditions => ["status like 'approved' AND space_id = ?", @space.id],
                                                    :include => :user,
                                                    :page => params[:page],
                                                    :order => 'updated_at DESC',
                                                    :per_page => AppConfig.items_per_page)
    else
      qry = params[:search_user] + '%'
      @memberships = UserSpaceAssociation.paginate(
        :conditions => ["user_space_associations.status like 'approved' AND user_space_associations.space_id = ? AND (users.first_name LIKE ? OR users.last_name LIKE ? OR users.login LIKE ?)",
          @space.id, qry,qry,qry ],
          :include => :user,
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

  # lista redes das quais o usuário corrente é membro
  #TODO mover para user
  def member
    @spaces = current_user.spaces
  end

  # lista redes das quais usuário corrente é dono
  #TODO mover para user
  def owner
    @spaces = current_user.spaces_owned
  end

  # lista todos os membros da escola
  #TODO mover para user
  def members

    @members = @space.user_space_associations.paginate(  #optei por .users ao inves de .students
                                                         :page => params[:page],
                                                         :order => 'updated_at DESC',
                                                         :per_page => AppConfig.users_per_page)
                                                         @member_type = "membros"

                                                         respond_to do |format|
                                                           format.html {
                                                             render "view_members"
                                                           }
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
      @statuses = @space.recent_activity(0,10)
      @bulletins = @space.bulletins.find(:all, :conditions => "state LIKE 'approved'", :order => "created_at DESC", :limit => 5)
    end

    respond_to do |format|
      if @space
        @status = Status.new

        format.html
        format.xml  { render :xml => @space }
      else
        format.html {
          flash[:error] = "O espaço \"" + params[:id] + "\" não existe ou não está cadastrada no Redu."
          redirect_to spaces_path
        }
      end
    end
  end

  def cancel
    @course = Course.find(params[:course_id])
    session[:space_step] = session[:space_params] = nil
    redirect_to(environment_course_path(@course.environment, @course))
  end

  # GET /spaces/new
  # GET /spaces/new.xml
  def new
    session[:space_params] ||= {}
    @space = Space.new(session[:space_params])
    @course = Course.find(params[:course_id])
    authorize! :manage, @course
    @environment = @course.environment
    @space.current_step = session[:space_step]
  end

  # GET /spaces/1/edit
  def edit
  end

  # POST /spaces
  # POST /spaces.xml
  def create
    session[:space_params].deep_merge!(params[:space]) if params[:space]
    @space = Space.new(session[:space_params])

    @course = @space.course
    authorize! :manage, @course
    @environment = @course.environment
    @space.owner = current_user
    @space.current_step = session[:space_step]
    if @space.valid?
      if params[:back_button]
        @space.previous_step
      elsif @space.last_step?
        @space.save if @space.all_valid?
      else
        @space.next_step
      end
      session[:space_step] = @space.current_step
    end
    if @space.new_record?
      render "new"
    else
      UserSpaceAssociation.create({:user => current_user, :space => @space, :status => "approved", :role_id => 4}) #:role => Role[:space_admin]
      Forum.create(:name => "Fórum do espaço #{@space.name}", :description => "Este fórum pertence ao espaço #{@space.name}. Apenas os participantes deste espaço podem visualizá-lo. Troque ideias, participe!", :space_id => @space.id)

      course_users = UserCourseAssociation.all(:conditions => ["state LIKE ? AND course_id = ?", 'approved', @space.course.id])

      course_users.each do |assoc|
        UserSpaceAssociation.create({:user_id => assoc.user_id, :space => @space, :status => "approved", :role_id => assoc.role_id})
      end

      session[:space_step] = session[:space_params] = nil
      flash[:notice] = "Rede criada!"
      redirect_to @space
    end
  end

  # PUT /spaces/1
  # PUT /spaces/1.xml
  def update
    unless params[:only_image]
      params[:space][:audience_ids] ||= []
    end

    respond_to do |format|
      if @space.update_attributes(params[:space])
        if params[:space][:subscription_type].eql? "1" # Entrada de membros passou a ser livre, aprovar todos os membros pendentes
          UserSpaceAssociation.update_all("status = 'approved'", ["space_id = ? AND status = 'pending'", @space.id])
        end
        flash[:notice] = 'O espaço foi atualizado com sucesso!'
        format.html { redirect_to(@space) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
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
    @space.published = 1
    @space.save

    flash[:notice] = "O space #{@space.name} foi publicado."
    redirect_to space_path(@space)
  end

  def unpublish
    @space.published = 0
    @space.save

    flash[:notice] = "O space #{@space.name} foi despublicado."
    redirect_to space_path(@space)
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
