class CoursesController < BaseController
  layout "environment"
  load_resource :environment
  load_and_authorize_resource :course, :through => :environment,
    :except => [:index]

  rescue_from CanCan::AccessDenied do |exception|
    raise if cannot? :preview, @course

    flash[:notice] = "Você não tem acesso a essa página"
    redirect_to preview_environment_course_path(@environment, @course)
  end

  def show
    @spaces = @course.spaces.published.
      paginate(:page => params[:page], :order => 'name ASC',
               :per_page => AppConfig.items_per_page)

    respond_to do |format|
      format.html do
        render :template => 'courses/new/show', :layout => 'new/application'
      end
      format.js { render :template => 'courses/new/show' }
    end
  end

  def edit
    @header_course = @course.clone

    respond_to do |format|
      format.html do
        render :template => "courses/new/edit", :layout => "new/application"
      end
    end
  end

  def destroy
    @course.destroy

    respond_to do |format|
      flash[:notice] = "Curso removido."
      format.html { redirect_to(environment_path(@environment)) }
      format.xml  { head :ok }
    end
  end

  def update
    @header_course = @course.clone

    respond_to do |format|
      if @course.update_attributes(params[:course])
        if params[:course][:subscription_type].eql? "1" # Entrada de membros passou a ser livre, aprovar todos os membros pendentes
          @course.user_course_associations.all(:conditions => { :state => 'waiting'}).each do |ass|
            ass.approve!
            @course.create_hierarchy_associations(ass.user, ass.role)
          end

        end

        flash[:notice] = 'O curso foi editado.'
        format.html { redirect_to(environment_course_path(@environment, @course)) }
        format.xml { head :ok }
      else
        format.html { render :template => "courses/new/edit",
          :layout => "new/application" }
        format.xml  { render :xml => @course.errors, :status => :unprocessable_entity }
      end
    end
  end

  def new

    respond_to do |format|
      format.html do
        render :template => 'courses/new/new', :layout => 'new/application'
      end
    end
  end

  def create
    authorize! :manage, @environment #Talvez seja necessario pois o @environment não está sendo autorizado.

    @course.owner = current_user
    @plan = Plan.from_preset(params[:plan].to_sym)
    @plan.user = current_user
    @course.verify_path! @environment.id

    respond_to do |format|
      if @course.save
        @course.create_quota
        @course.plan = @plan
        @plan.create_invoice_and_setup
        @environment.courses << @course
        format.html { redirect_to environment_course_path(@environment, @course) }
      else
        format.html { render :template => "courses/new/new",
          :layout => "new/application" }
      end
    end

  end

  # FIXME Remover lógica de user_id quando a listagem de cursos
  # não for mais mostrada no perfil do usuário.
  def index

    paginating_params = {
      :page => params[:page],
      :order => 'name ASC',
      :per_page => AppConfig.items_per_page
    }

    if params.has_key?(:user_id)
      @user = User.find(params[:user_id].to_i)
      paginating_params[:per_page] = 6
      @courses = @user.courses
    else
      if params.has_key? :role
        if params[:role] == 'student'
          @courses = Course.user_behave_as_student(current_user)
        elsif params[:role] == 'tutor'
          @courses = Course.user_behave_as_tutor(current_user)
        elsif params[:role] == 'teacher'
          @courses = Course.user_behave_as_teacher(current_user)
        elsif params[:role] == 'administrator'
          @courses = Course.user_behave_as_administrator(current_user)
        end
      else
        @courses = Course.published
      end

      if params.has_key?(:search) && params[:search] != ''
        search = params[:search].to_s.split
        @courses = @courses.name_like_all(search)
      end

      if params.has_key?(:audiences_ids)
        @courses = @courses.with_audiences(params[:audiences_ids])
      end

    end

    @courses = @courses.paginate(paginating_params)

    respond_to do |format|
      format.html do
        unless params[:user_id]
          render :template => 'courses/new/index', :layout => 'new/application'
        end
      end
      format.js do
        render :template => 'courses/new/index'
      end
    end
  end

  # Visão do Course para usuários não-membros.
  def preview
    #FIXME please. Used for redirect to a valid url
    if params[:id] == 'Primeiro Ano do Ensino Médio 2011'
      redirect_to preview_environment_course_path(@environment, Course.find(88)) and return
    end

    if (can? :read, @course) && (!can? :manage, @course)
      redirect_to environment_course_path(@environment, @course) and return
    end

    @spaces = @course.spaces.paginate(:page => params[:page],
                                      :order => 'name ASC',
                                      :per_page => AppConfig.items_per_page)
    respond_to do |format|
      format.html do
        render :template => 'courses/new/preview', :layout => 'new/application'
      end
      format.js do
        render :template => 'courses/new/preview'
      end
    end
  end

  # Aba Disciplinas.
  def admin_spaces
    # FIXME Refatorar para o modelo (conditions)
    @spaces = Space.paginate(:conditions => ["course_id = ?", @course.id],
                             :include => :owner,
                             :page => params[:page],
                             :order => 'updated_at DESC',
                             :per_page => AppConfig.items_per_page)

    respond_to do |format|
      format.html do
        render :template => "courses/new/admin_spaces",
          :layout => "new/application"
      end
      format.js do
        render :template => "courses/new/admin_spaces"
      end
    end
  end

  # Aba Moderação de Membros.
  def admin_members_requests
    # FIXME Refatorar para o modelo (conditions)
    @pending_members = UserCourseAssociation.paginate(:conditions => ["state LIKE 'waiting' AND course_id = ?", @course.id],
                                                      :page => params[:page],
                                                      :order => 'updated_at DESC',
                                                      :per_page => AppConfig.items_per_page)
    respond_to do |format|
      format.html do
        render :template => "courses/new/admin_member_requests",
          :layout => "new/application"
      end
      format.js
    end

  end

  # Modera os usuários.
  def moderate_members_requests
    if params[:member].nil?
      flash[:notice] = "Escolha, pelo menos, algum usuário."
    else
      approved = params[:member].reject{|k,v| v == 'reject'}
      rejected = params[:member].reject{|k,v| v == 'approve'}

      rejected.keys.each do |user_id|
        @course.user_course_associations.all(:conditions => {
          :user_id => user_id}).each do |ass|
          #TODO fazer isso em batch
          UserNotifier.deliver_reject_membership(ass.user, @course)
          ass.destroy
          end
      end

      # verifica se o limite de usuário foi atingido
      if @course.can_add_entry? and !approved.to_hash.empty?

        # calcula o total de usuarios que estão para ser aprovados
        # e só aprova aqueles que estiverem dentro do limite
        total_members = @course.approved_users.count + approved.count
        if total_members > @course.plan.members_limit
          # remove o usuários que passaram do limite
          (total_members - @course.plan.members_limit).times do
            approved.shift
          end
          flash[:notice] = "O limite máximo de usuários foi atigindo, apenas alguns membros foram moderados."
        else
          flash[:notice] = 'Membros moderados!'
        end

        approved.keys.each do |user_id|
          @course.user_course_associations.all(:conditions => {
            :user_id => user_id}).each do |ass|
            ass.approve!
            @course.create_hierarchy_associations(ass.user, ass.role)
            # TODO fazer isso em batch
            UserNotifier.deliver_approve_membership(ass.user, @course)
            end
        end
      else
        if rejected.to_hash.empty?
          flash[:notice] = "O limite máximo de usuários foi atingido. Não é possível adicionar mais usuários."
        else
          flash[:notice] = "O limite máximo de usuários foi atingido. Só os usuários rejeitados foram moderados."
        end
      end


    end

    redirect_to admin_members_requests_environment_course_path(@environment, @course)
  end

  # Associa um usuário a um Course (Ação de participar).
  def join

    authorize! :add_entry, @course
    association = UserCourseAssociation.create(:user_id => current_user.id,
                                               :course_id => @course.id,
                                               :role_id => Role[:member].id)

    if @course.subscription_type.eql? 1 # Todos podem participar, sem moderação
      association.approve!

      # Cria as associações no Environment do Course e em todos os seus Spaces.
      UserEnvironmentAssociation.create(:user_id => current_user.id, :environment_id => @course.environment.id,
                                        :role_id => Role[:member].id)
      @course.spaces.each do |space|
        UserSpaceAssociation.create(:user_id => current_user.id, :space_id => space.id,
                                    :role_id => Role[:member].id, :status => "approved") #FIXME tirar status quando remover moderacao de space
      end

      flash[:notice] = "Você agora faz parte do curso #{@course.name}"
      redirect_to environment_course_path(@course.environment, @course)
    else
      flash[:notice] = "Seu pedido de participação foi feito. Aguarde a moderação."
      redirect_to preview_environment_course_path(@course.environment, @course)
    end
  end


  # Desassocia um usuário de um Course (Ação de sair do Course).
  def unjoin
    @course.unjoin current_user

    flash[:notice] = "Você não participa mais do curso #{@course.name}"
    redirect_to environment_course_path(@course.environment, @course)
  end

  def publish
    if @course.can_be_published?
      @course.published = 1
      @course.save
      flash[:notice] = "O curso #{@course.name} foi publicado."
    else
      flash[:notice] = "O curso não pode ser publicado, crie e publique disciplinas!"
    end

    redirect_to environment_course_path(@environment, @course)
  end

  def unpublish
    @course.published = 0
    @course.save

    flash[:notice] = "O curso #{@course.name} foi despublicado."
    redirect_to environment_course_path(@environment, @course)
  end

  # Aba Membros.
  def admin_members
    @memberships = UserCourseAssociation.paginate(
      :conditions => ["course_id = ? AND state LIKE ? ", @course.id, 'approved'],
      :include => [{ :user => {:user_space_associations => :space} }],
      :page => params[:page],
      :order => 'updated_at DESC',
      :per_page => AppConfig.items_per_page)

      respond_to do |format|
        format.html do
          render :template => "courses/new/admin_members",
            :layout => "new/application"
        end
        format.js { render :template => 'courses/new/admin_members' }
      end
  end

  # Remove um ou mais usuários de um Environment destruindo todos os relacionamentos
  # entre usuário e os níveis mais baixos da hierarquia.
  def destroy_members
    # Course.id do environment
    spaces = @course.spaces
    users_ids = []
    users_ids = params[:users].collect{|u| u.to_i} if params[:users]

    unless users_ids.empty?
      User.find(:all,
                :conditions => {:id => users_ids},
                :include => [:user_course_associations,
                  :user_space_associations]).each do |user|

        user.spaces.delete(spaces)
        user.courses.delete(@course)
                  end
      flash[:notice] = "Os usuários foram removidos do curso #{@course.name}"
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

    @memberships = @course.user_course_associations.approved.with_roles(roles)
    @memberships = @memberships.with_keyword(keyword).paginate(
      :include => [{ :user => {:user_space_associations => :space} }],
      :page => params[:page],
      :order => 'user_course_associations.updated_at DESC',
      :per_page => AppConfig.items_per_page)

      respond_to do |format|
        format.js do
          render :update do |page|
            if @memberships.empty?
              page.replace_html 'user_list',
                "<div class=\"box_notice\">Nenhum usuário encontrado.</div>"
            else
              page.replace_html 'user_list',
                :partial => 'courses/new/user_list_admin',
                :locals => {:memberships => @memberships}
            end
          end
        end
      end
  end

  # Listagem de usuários do Course
  def users
    @sidebar_preview = true if params.has_key?(:preview) &&
                              params[:preview] == 'true'
    @users = @course.approved_users.
      paginate(:page => params[:page], :order => 'first_name ASC', :per_page => 18)

    respond_to do |format|
      format.html do
        render :template => 'courses/new/users', :layout => 'new/application'
      end
      format.js { render :template => 'courses/new/users' }
    end
  end

  # Aceitar convite para o Course
  def accept
    authorize! :add_entry, @course

    assoc = current_user.get_association_with @course
    assoc.accept!

    respond_to do |format|
      format.html do
        redirect_to home_user_path(current_user)
      end
      format.js do
        render :nothing => true
      end
    end
  end

  # Negar convite para o Course
  def deny
    assoc = current_user.get_association_with @course
    assoc.deny!
    assoc.destroy

    respond_to do |format|
      format.html do
        redirect_to home_user_path(current_user)
      end
      format.js do
        render :nothing => true
      end
    end
  end

  def invite_members
    @users = params[:users] || ""
    @users = @users.split(",").uniq.compact
    @users = User.find(@users)

    @users.each do |user|
      @course.invite(user)
    end

    respond_to do |format|
      if @users.empty?
        flash[:error] = "Nenhum usuário foi informado."
      else
        flash[:notice] = "Os usuários foram convidados via e-mail."
      end

      format.html do
        redirect_to admin_invitations_environment_course_path(@environment, @course)
      end
    end
  end

  def admin_invitations
    respond_to do |format|
      format.html do
        render :template => 'courses/new/admin_invitations', :layout => 'new/application'
      end
    end
  end

end
