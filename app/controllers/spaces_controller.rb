class SpacesController < BaseController

  before_filter :login_required,  :except => [:join, :unjoin, :member, :index]
  after_filter :create_activity, :only => [:create]
  # Usado para proteger acoes perigosas (só para admin)
  before_filter :except =>
  [:new, :create, :show, :vote, :index, :join, :unjoin, :member, :onwer, :members, :teachers, :take_ownership] do |controller|
    controller.space_admin_required(controller.params[:id]) if controller.params and controller.params[:id]
  end
  before_filter :can_be_owner_required, :only => :take_ownership
  before_filter :is_not_member_required, :only => :join

  def remove_asset
    case params[:asset_type]
    when 'Lecture'
      msg = "Aula removida da rede"
    when 'Exam'
      msg = "Exame removido da rede"
    end

    @asset = SpaceAsset.first(:conditions => ["asset_type LIKE ? AND asset_id = ? and space_id = ?", params[:asset_type], params[:asset_id], params[:id]])

    if @asset
      @asset.destroy
      flash[:notice] = msg
    else
      flash[:notice] = "Não foi possível remover o conteúdo selecionado"
    end

    redirect_to space_lectures_path(:space_id => params[:id])
  end

  def take_ownership
    @space = Space.find(params[:id])
    @space.update_attribute(:owner, current_user)
    flash[:notice] = "Você é o novo dono desta rede!"
    redirect_to @space
  end

  def vote
    @space = Space.find(params[:id])
    current_user.vote(@space, params[:like])
    respond_to do |format|
      format.js { render :template => 'shared/like.rjs', :locals => { :votes_for => @space.votes_for().to_s} } 
    end
  end

  def look_and_feel
    @space = Space.find(params[:id])
  end

  def set_theme
    @space = Space.find(params[:id])
    @space.update_attributes(params[:space])

    flash[:notice] = "Tema modificado com sucesso!"
    redirect_to look_and_feel_space_path
  end

  ##  Admin actions
  def new_space_admin
    @user_space_association = UserSpaceAssociation.new

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @space }
    end
  end

  ### Space Admin actions
  def invalidate_keys(access_key) # 'troca' um conjunto de chaves
    #TODO
  end

  def join
    @space = Space.find(params[:id])
    @association = UserSpaceAssociation.new
    @association.user = current_user
    @association.space = @space

    case @space.subscription_type

    when 1 # anyone can join
      @association.status = "approved"

      if @association.save
        flash[:notice] = "Você está participando da rede agora!"
      end

    when 2 # moderated
      @association.status = "pending"

      if @association.save
        flash[:notice] = "Seu pedido de participação está sendo moderado pelos administradores da rede."
        UserNotifier.deliver_pending_membership(current_user, @space) # TODO fazer isso em batc
      end
    end

    respond_to do |format|
      format.html { redirect_to(@space) }
    end
  end

  def unjoin
    @space = Space.find(params[:id])
    @association = UserSpaceAssociation.find(:first, :conditions => ["user_id = ? AND space_id = ?",current_user.id, @space.id ])

    if @association.destroy
      flash[:notice] = "Você saiu da rede"
    end

    respond_to do |format|
      format.html { redirect_to(@space) }
    end
  end

  def manage
    @space = Space.find(params[:id])
  end

  # Modercacao
  def admin_requests
    @space = Space.find(params[:id])
    # TODO colocar a consulta a seguir como um atributo de space (como em space.teachers)
    @pending_members = UserSpaceAssociation.paginate(:conditions => ["user_space_associations.status like 'pending' AND space_id = ?", @space.id],
                                                      :page => params[:page],
                                                      :order => 'updated_at DESC',
                                                      :per_page => AppConfig.items_per_page)

    respond_to do |format|
      format.html #{ render :action => "my" }
    end
  end

  def admin_members
    @space = Space.find(params[:id]) # TODO 2 consultas ao inves de uma?
    @memberships = UserSpaceAssociation.paginate(:conditions => ["status like 'approved' AND space_id = ?", @space.id],
                                                  :include => :user,
                                                  :page => params[:page],
                                                  :order => 'updated_at DESC',
                                                  :per_page => AppConfig.items_per_page)
    respond_to do |format|
      format.html
    end
  end

  def admin_submissions
    @space = Space.find(params[:id])
    @lectures = Lecture.paginate(:conditions => ["published = 1 AND state LIKE ?", "waiting"],
                               :include => :owner,
                               :page => params[:page],
                               :order => 'updated_at DESC',
                               :per_page => AppConfig.items_per_page)

    respond_to do |format|
      format.html #{ render :action => "my" }
      format.xml  { render :xml => @lectures }
    end
  end

  def admin_bulletins
    @space = Space.find(params[:id])
    @bulletins = Bulletin.paginate(:conditions => ["space_id = ? AND state LIKE ?", @space.id, "waiting"],
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
    @events = Event.paginate(:conditions => ["space_id = ? AND state LIKE ?", @space.id, "waiting"],
                             :include => :owner,
                             :page => params[:page],
                             :order => 'updated_at ASC',
                             :per_page => 20)

    respond_to do |format|
      format.html
    end
  end

  def moderate_requests
    @space = Space.find(params[:id])

    approved = params[:member].reject{|k,v| v == 'reject'}
    rejected = params[:member].reject{|k,v| v == 'approve'}

    #atualiza status da associacao
    approved.keys.each do |user_id|
      UserSpaceAssociation.update_all("status = 'approved'", :user_id => user_id,  :space_id => @space.id)
    end

    rejected.keys.each do |user_id|
      UserSpaceAssociation.update_all("status = 'disaproved'", :user_id => user_id,  :space_id => @space.id)
    end

    #pega usuários para enviar emails
    @approved_members = User.all(:conditions => ["id IN (?)", approved.keys]) unless approved.empty?
    @rejected_members = User.all(:conditions => ["id IN (?)", rejected.keys]) unless rejected.empty?

    if @approved_members
      for member in @approved_members
        UserNotifier.deliver_approve_membership(member, @space) # TODO fazer isso em batch
      end
    end

    flash[:notice] = 'Solicitacões moderadas!'
    redirect_to admin_requests_space_path(@space)
  end

  def moderate_members
    @space = Space.find(params[:id]) # TODO realmente necessário?

    case params[:submission_type]
    when '0' # remove selected
      @removed_users = User.all(:conditions => ["id IN (?)", params[:users].join(',')]) unless params[:users].empty?

      # TODO destroy_all ou delete_all?
      UserSpaceAssociation.delete_all(["user_id IN (?) AND space_id = ?", params[:users].join(','), @space.id])


      for user in @removed_users # TODO fazer um remove all?
        UserNotifier.deliver_remove_membership(user, @space) # TODO fazer isso em batch
      end
    when '1' # moderate roles
      UserSpaceAssociation.update_all(["role_id = ?", params[:role_id]],
                                       ["status like 'approved' AND space_id = ? AND user_id IN (?)", @space.id, params[:users].join(',') ])  if params[:role_id]

      # TODO enviar emails para usuários dizendo que foram promovidos?
    end
    flash[:notice] = 'Usuários moderados!'
    redirect_to admin_members_space_path
  end

  def search_users_admin
    @space = Space.find(params[:id])
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

  def moderate_submissions
    approved = params[:submission].reject{|k,v| v == 'reject'}
    rejected = params[:submission].reject{|k,v| v == 'approve'}
    approved_ids = approved.keys.join(',')
    rejected_ids = rejected.keys.join(',')

    @space = Space.find(params[:space_id])

    SpaceAsset.update_all( "status = 'approved'", ["asset_id IN (?)", @approve_ids.join(',') ]) if @approve_ids
    SpaceAsset.update_all( "status = 'disaproved'",["asset_id IN (?)", @approve_ids.join(',') ]) if @disapprove_ids

    @approved_members = User.all(:conditions => ["id IN (?)", approved_ids]) unless approved_ids.empty?
    @rejected_members = User.all(:conditions => ["id IN (?)", rejected_ids]) unless rejected_ids.empty?

    for member in @approved_members
      UserNotifier.deliver_approve_membership(member, @space) # TODO fazer isso em batch
    end

    flash[:notice] = 'Solicitacões moderadas!'
    redirect_to pending_members_space_path
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

    @space = Space.find(params[:id])
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

    @space = Space.find(params[:id])
    redirect_to admin_events_space_path(@space)
  end

  # usuário entra na rede
  def associate
    @space = Space.find(params[:id])
    @user = User.find(params[:user_id])  # TODO precisa mesmo recuperar o usuário no bd?
    @user_space_association = UserSpaceAssociation.find(:first, :include => :access_key, :conditions => ["access_keys.key = ?", params[:user_key]])

    #TODO case?
    if @user_space_association
      if @user_space_association.access_key.expiration_date.to_time < Time.now # verifica a data da validade da chave
        if @space &&  @user_space_association.space == @space
          if @user && !@user_space_association.user # cada chave só poderá ser usada uma vez, sem troca de aluno
            @user_space_association.user = @user

            if @user_space_association.save
              flash[:notice] = 'Usuário associado à escola!'
            else
              flash[:notice] = 'Associação à escola falhou'
            end
          else
            flash[:notice] = 'Essa chave já está em uso'
          end
        else
          flash[:notice] = 'Essa chave pertence à outra escola'
        end
      else
        flash[:notice] = 'O prazo de validade desta chave expirou. Contate o administrador da sua escola.'
      end
    else
      flash[:notice] = 'Chave inválida'
    end

    respond_to do |format|
      format.html { redirect_to(@space) }
    end
  end

  # lista redes das quais o usuário corrente é membro
  def member
    @spaces = current_user.spaces
  end

  # lista redes das quais usuário corrente é dono
  def owner
    @spaces = current_user.spaces_owned
  end

  # lista todos os membros da escola
  def members
    @space = Space.find(params[:id]) #TODO duas queries que poderiam ser apenas 1
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
  def teachers
    @space = Space.find(params[:id]) #TODO duas queries que poderiam ser apenas 1

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
    cond = Caboose::EZ::Condition.new
    cond.append ["redu_category_id = ?", params[:area]] if params[:area] and params[:area].downcase != 'all'

    paginating_params = {
      :conditions => cond.to_sql,
      :page => params[:page],
      :order => (params[:sort]) ? params[:sort] + ' DESC' : 'created_at DESC',
      :per_page => 12
    }

    @spaces =  Space.inner_categories.paginate(paginating_params) if params[:area] and params[:area].downcase != 'all'

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
      format.xml  { render :xml => @lectures }
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
    @space = Space.find(params[:id]) # TODO colocar como um filtro (find_space)

    if @space and @space.removed
      redirect_to removed_page_path and return
    end

    if @space
      @statuses = @space.recent_activity(0,10)

      @featured = @space.featured_lectures(3)
      @brand_new = @space.lectures.find(:first, :order => "created_at DESC")
      @lectures = @space.lectures.paginate(:conditions =>
                                          ["published = 1"],
                                            :include => :owner,
                                            :page => params[:page],
                                            :order => 'updated_at DESC',
                                            :per_page => AppConfig.items_per_page)
                                          @bulletins = @space.bulletins.find(:all, :conditions => "state LIKE 'approved'", :order => "created_at DESC", :limit => 5)
    end

    respond_to do |format|
      if @space
        @status = Status.new

        format.html
        format.xml  { render :xml => @space }
      else
        format.html {
          flash[:error] = "A escola \"" + params[:id] + "\" não existe ou não está cadastrada no Redu."
          redirect_to spaces_path
        }
      end
    end
  end

  def cancel
    session[:space_step] = session[:space_params] = nil
    redirect_to spaces_path
  end

  # GET /spaces/new
  # GET /spaces/new.xml
  def new
    @course = Course.find(params[:course_id])
    session[:space_params] ||= {}
    @space = Space.new(session[:space_params])
    @space.current_step = session[:space_step]
  end

  # GET /spaces/1/edit
  def edit
    @space = Space.find(params[:id])
  end

  # POST /spaces
  # POST /spaces.xml
  def create

    session[:space_params].deep_merge!(params[:space]) if params[:space]
    @space = Space.new(session[:space_params])
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
      forum = Forum.create(:name => "Fórum do espaço #{@space.name}", :description => "Este fórum pertence ao espaço #{@space.name} e apenas os participates deste espaço podem visualizá-lo. Troque ideias, participe!", :space_id => @space.id)
      session[:space_step] = session[:space_params] = nil
      flash[:notice] = "Rede criada!"
      redirect_to @space
    end
  end

  # PUT /spaces/1
  # PUT /spaces/1.xml
  def update
    unless params[:only_image]
      params[:space][:category_ids] ||= []
      params[:space][:audience_ids] ||= []
    end
    @space = Space.find(params[:id])

    respond_to do |format|
      if @space.update_attributes(params[:space])
        if params[:space][:subscription_type].eql? "1" # Entrada de membros passou a ser livre, aprovar todos os membros pendentes
          UserSpaceAssociation.update_all("status = 'approved'", ["space_id = ? AND status = 'pending'", @space.id])
        end
        flash[:notice] = 'A escola foi atualizada com sucesso!'
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
    @space = Space.find(params[:id])
    @space.destroy

    respond_to do |format|
      format.html { redirect_to(environment_course_path(@space.course.environment, @space.course)) }
      format.xml  { head :ok }
    end
  end

  protected

  def can_be_owner_required
    @space = Space.find(params[:id])

    current_user.can_be_owner?(@space) ? true : access_denied
  end

  def is_not_member_required
    @space = Space.find(params[:id])
    if current_user.get_association_with(@space)
      redirect_to space_path(@space)
    end
  end

end
