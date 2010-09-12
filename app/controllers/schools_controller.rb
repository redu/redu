class SchoolsController < BaseController
  layout 'new_application'
  
  before_filter :login_required,  :except => [:join, :unjoin, :member]
  #before_filter :admin_required,  :only => [:new, :create]
  #before_filter :school_admin_required,  :except => [:new, :create, :vote]
   after_filter :create_activity, :only => [:create]


  before_filter :except => [:new, :create, :vote, :show, :index, :join, :unjoin, 
                             :member, :onwer, :members, :teachers, :take_ownership] do |controller| 
    controller.school_admin_required(controller.params[:id]) if controller.params and controller.params[:id]
  end
  
  before_filter :can_be_owner_required, :only => :take_ownership
  
  
  def remove_asset
    case params[:asset_type]
      when 'Course'
      msg = "Aula removida da rede"
      when 'Exam'
      msg = "Exame removido da rede"
    end
    
     @asset = SchoolAsset.first(:conditions => ["asset_type LIKE ? AND asset_id = ? and school_id = ?", params[:asset_type], params[:asset_id], params[:id]])
    
    if @asset
      @asset.destroy
      flash[:notice] = msg
    else
      flash[:notice] = "Não foi possível remover o conteúdo selecionado"
    end
    
    
    redirect_to school_courses_path(:school_id => params[:id])
    
  end
  
  

  
  
  def take_ownership
     @school = School.find(params[:id])
     @school.update_attribute(:owner, current_user)
     flash[:notice] = "Você é o novo dono desta rede!"
     redirect_to @school
  end
  
  def vote
    @school = School.find(params[:id])
    current_user.vote(@school, params[:like])
    respond_to do |format|
      format.js do 
        render :update do |page|
          page << "$('#like_spinner').hide()"
          page << "$('#like_link').show()"
          page << "$('#like_link').attr('onclick', 'return false;')"
           page << "$('#like_count').html('" + @school.votes_for().to_s + "')" # TODO performance + uma consulta?
        end
      end
    end
  end
  
  
  def look_and_feel
    @school = School.find(params[:id])
  end

  def set_theme
    @school = School.find(params[:id])
    @school.update_attributes(params[:school])
   
    #@school.update_attribute(:theme, params[:theme])
    flash[:notice] = "Tema modificado com sucesso!"
    redirect_to look_and_feel_school_path
  end

  ##  Admin actions  
  def new_school_admin
    @user_school_association = UserSchoolAssociation.new
    
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @school }
    end
  end
  
  ### School Admin actions
  def invalidate_keys(access_key) # 'troca' um conjunto de chaves
    
  end
  
  def join
    @school = School.find(params[:id])
    
    @association = UserSchoolAssociation.new
    @association.user = current_user
    @association.school = @school
    
    case @school.subscription_type 
      
      when 1 # anyone can join
        @association.status = "approved"
        
        if @association.save
          flash[:notice] = "Você está participando da rede agora!"
        end
      
      when 2 # moderated
        @association.status = "pending"
        
        if @association.save
          flash[:notice] = "Seu pedido de participação está sendo moderado pelos administradores da rede."
           UserNotifier.deliver_pending_membership(current_user, @school) # TODO fazer isso em batc
        end
      
    end
    
    respond_to do |format|
          format.html { redirect_to(@school) }
    end
    
    
    
  end
  
  
  def unjoin
    @school = School.find(params[:id])
    
    @association = UserSchoolAssociation.find(:first, :conditions => ["user_id = ? AND school_id = ?",current_user.id, @school.id ])
    
    if @association.destroy
      flash[:notice] = "Você saiu da rede"
    end
    
    respond_to do |format|
      format.html { redirect_to(@school) }
    end
    
  end
  
  
  def manage
     @school = School.find(params[:id])
  end
  
  ##
  #   MODERAÇÃO
  ##
  
  
  def admin_requests 
    @school = School.find(params[:id])
    # TODO colocar a consulta a seguir como um atributo de school (como em school.teachers)
    @pending_members = UserSchoolAssociation.paginate(:conditions => ["user_school_associations.status like 'pending' AND school_id = ?", @school.id], 
      :page => params[:page], 
      :order => 'updated_at DESC', 
      :per_page => AppConfig.items_per_page)
    
    respond_to do |format|
      format.html #{ render :action => "my" }
      #format.xml  { render :xml => @courses }
    end
    
  end
  
  def admin_members
    @school = School.find(params[:id]) # TODO 2 consultas ao inves de uma? 
    
    @memberships = UserSchoolAssociation.paginate(:conditions => ["status like 'approved' AND school_id = ?", @school.id],
    :include => :user,
  :page => params[:page], 
  :order => 'updated_at DESC', 
  :per_page => AppConfig.items_per_page)
    
#    @users = @school.users.paginate(
#      :page => params[:page], 
#      :order => 'created_at ASC', 
#      :per_page => 20)
    
    respond_to do |format|
      format.html 
    end
  end
  
  
  def admin_submissions 
    @school = School.find(params[:id])
    
    @courses = Course.paginate(:conditions => ["published = 1 AND state LIKE ?", "waiting"], 
      :include => :owner, 
      :page => params[:page], 
      :order => 'updated_at DESC', 
      :per_page => AppConfig.items_per_page)
    
    respond_to do |format|
      format.html #{ render :action => "my" }
      format.xml  { render :xml => @courses }
    end
    
  end
  
  def admin_bulletins
    @school = School.find(params[:id])

    @bulletins = Bulletin.paginate(:conditions => ["school_id = ? AND state LIKE ?", @school.id, "waiting"], 
        :include => :owner, 
        :page => params[:page], 
        :order => 'updated_at ASC', 
        :per_page => 20)

      respond_to do |format|
        format.html 
      end
  end
  
  def admin_events
    @school = School.find(params[:id])

    @events = Event.paginate(:conditions => ["school_id = ? AND state LIKE ?", @school.id, "waiting"], 
        :include => :owner, 
        :page => params[:page], 
        :order => 'updated_at ASC', 
        :per_page => 20)

      respond_to do |format|
        format.html 
      end
  end
  
  ### 
  
  
  def moderate_requests
    @school = School.find(params[:id])
    
    approved = params[:member].reject{|k,v| v == 'reject'}
    rejected = params[:member].reject{|k,v| v == 'approve'}
    
    #atualiza status da associacao    
    approved.keys.each do |user_id|
      UserSchoolAssociation.update_all("status = 'approved'", :user_id => user_id,  :school_id => @school.id)
    end

    rejected.keys.each do |user_id|
      UserSchoolAssociation.update_all("status = 'disaproved'", :user_id => user_id,  :school_id => @school.id)
    end

    #pega usuários para enviar emails
    @approved_members = User.all(:conditions => ["id IN (?)", approved.keys]) unless approved.empty?
    @rejected_members = User.all(:conditions => ["id IN (?)", rejected.keys]) unless rejected.empty?
    
    if @approved_members
      for member in @approved_members
        UserNotifier.deliver_approve_membership(member, @school) # TODO fazer isso em batch
      end
    end
    
    #    for member in @rejected_members #TODO mandar email para os que não foram aceitos na rede???
    #       UserNotifier.deliver_reject_member(course, nil) # TODO fazer isso em batch
    #    end
    
    flash[:notice] = 'Solicitacões moderadas!'
    redirect_to admin_requests_school_path(@school)
    
  end
  
  
  def moderate_members
    @school = School.find(params[:id]) # TODO realmente necessário?
    
    case params[:submission_type]
      
      when '0' # remove selected
          @removed_users = User.all(:conditions => ["id IN (?)", params[:users].join(',')]) unless params[:users].empty?
          
          # TODO destroy_all ou delete_all?
          UserSchoolAssociation.delete_all(["user_id IN (?) AND school_id = ?", params[:users].join(','), @school.id]) 
          
          
          for user in @removed_users # TODO fazer um remove all?
            UserNotifier.deliver_remove_membership(user, @school) # TODO fazer isso em batch
          end
      
      when '1' # moderate roles
          UserSchoolAssociation.update_all(["role_id = ?", params[:role_id]], 
          ["status like 'approved' AND school_id = ? AND user_id IN (?)", @school.id, params[:users].join(',') ])  if params[:role_id]
          
          # TODO enviar emails para usuários dizendo que foram promovidos?
    end
    flash[:notice] = 'Usuários moderados!'
    redirect_to admin_members_school_path
  end
  
  def search_users_admin
    @school = School.find(params[:id])
    
    if params[:search_user].empty?
      @memberships = UserSchoolAssociation.paginate(:conditions => ["status like 'approved' AND school_id = ?", @school.id],
        :include => :user,
      :page => params[:page], 
      :order => 'updated_at DESC', 
      :per_page => AppConfig.items_per_page)
    else
      qry = params[:search_user] + '%'
       @memberships = UserSchoolAssociation.paginate(
       :conditions => ["user_school_associations.status like 'approved' AND user_school_associations.school_id = ? AND (users.first_name LIKE ? OR users.last_name LIKE ? OR users.login LIKE ?)",
       @school.id, qry,qry,qry ],
       :include => :user,
      :page => params[:page], 
      :order => 'user_school_associations.updated_at DESC', 
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
    
    @school = School.find(params[:school_id])
    
    
   SchoolAsset.update_all( "status = 'approved'", ["asset_id IN (?)", @approve_ids.join(',') ]) if @approve_ids
   SchoolAsset.update_all( "status = 'disaproved'",["asset_id IN (?)", @approve_ids.join(',') ]) if @disapprove_ids
    
    @approved_members = User.all(:conditions => ["id IN (?)", approved_ids]) unless approved_ids.empty?
    @rejected_members = User.all(:conditions => ["id IN (?)", rejected_ids]) unless rejected_ids.empty?
    
    for member in @approved_members
      UserNotifier.deliver_approve_membership(member, @school) # TODO fazer isso em batch
    end
    
    #    for member in @rejected_members #TODO mandar email para os que não foram aceitos na rede???
    #       UserNotifier.deliver_reject_member(course, nil) # TODO fazer isso em batch
    #    end
    
    flash[:notice] = 'Solicitacões moderadas!'
    redirect_to pending_members_school_path
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

    @school = School.find(params[:id])
    redirect_to admin_bulletins_school_path(@school)
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

     @school = School.find(params[:id])
     redirect_to admin_events_school_path(@school)
   end

 
 ################################################
  
  
  
  # usuário entra na rede
  def associate
    @school = School.find(params[:id])
    @user = User.find(params[:user_id])  # TODO precisa mesmo recuperar o usuário no bd?
    
    #@user_school_association = UserSchoolAssociation.find(:first, :joins => :access_key, :conditions => ["access_keys.key = ?", params[:user_key]])  
    @user_school_association = UserSchoolAssociation.find(:first, :include => :access_key, :conditions => ["access_keys.key = ?", params[:user_key]])  
    
    if @user_school_association
      
      if @user_school_association.access_key.expiration_date.to_time < Time.now # verifica a data da validade da chave
        
        if @school &&  @user_school_association.school == @school
          
          if @user && !@user_school_association.user # cada chave só poderá ser usada uma vez, sem troca de aluno
            
            
            @user_school_association.user = @user
            
            if @user_school_association.save
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
      format.html { redirect_to(@school) }
    end
    
  end
  
  ## LISTS
  
  # lista redes das quais o usuário corrente é membro
  def member 
    @schools = current_user.schools
    
  end
  
  # lista redes das quais usuário corrente é dono
  def owner
    #@user_school_association_array = UserSchoolAssociation.find(:all, :conditions => ["user_id = ? AND role_id = ?", current_user.id, 4])
   @schools = current_user.schools_owned
   
  end
  
  # lista todos os membros da escola
  def members
    @school = School.find(params[:id]) #TODO duas queries que poderiam ser apenas 1
    
#     @members = @school.users.paginate(  #optei por .users ao inves de .students
#      :page => params[:page], 
#      :order => 'updated_at DESC', 
#      :per_page => AppConfig.users_per_page)
    
     @members = @school.user_school_associations.paginate(  #optei por .users ao inves de .students
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
    @school = School.find(params[:id]) #TODO duas queries que poderiam ser apenas 1
    
     @members = @school.teachers.paginate( 
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
  
  # GET /schools
  # GET /schools.xml
  def index
    cond = Caboose::EZ::Condition.new
    cond.append ["area_id = ?", params[:area]] if params[:area] and params[:area].downcase != 'all'
    cond.append ["audience_id = ?", params[:audience]] if params[:audience]
    
    
    
     paginating_params = {
      :conditions => cond.to_sql,
      :page => params[:page], 
      :order => (params[:sort]) ? params[:sort] + ' DESC' : 'created_at DESC', 
      :per_page => 12 
    }
    
    @schools =  School.redu_categories_id(params[:area]).paginate(paginating_params) if params[:area] and params[:area].downcase != 'all'
   
    
    
    if params[:user_id] # aulas do usuario
      @user = User.find_by_login(params[:user_id]) 
      @user = User.find(params[:user_id]) unless @user
      @schools = @user.schools.paginate(paginating_params)
      
    elsif params[:search] # search
      @schools = School.name_like_all(params[:search].to_s.split).ascend_by_name.paginate(paginating_params)
    else
      @schools = School.all.paginate(paginating_params)
    end


    respond_to do |format|
      format.xml  { render :xml => @courses }
      format.html do 
        if @user
          #format.js
          redirect_to @user
        end
      end
      format.js  do
        if @user
          render :update do |page|
            page.replace_html  'tabs-4-content', :partial => 'user_schools'
          end
        end
      end
    end
  end
  
  # GET /schools/1
  # GET /schools/1.xml
  def show
    @school = School.find(params[:id]) # TODO colocar como um filtro (find_school)
    
    if @school and @school.removed
        redirect_to removed_page_path and return
    end
    
    
    if @school
      @statuses = @school.recent_activity(0,10)
      
      @featured = @school.featured_courses(2)
      @brand_new = @school.courses.find(:first, :order => "created_at DESC")
      @courses = @school.courses.paginate(:conditions => 
        ["published = 1"], 
        :include => :owner, 
        :page => params[:page], 
        :order => 'updated_at DESC', 
        :per_page => AppConfig.items_per_page)
			@bulletins = @school.bulletins.find(:all, :conditions => "state LIKE 'approved'", :order => "created_at DESC", :limit => 5)

    end
      
    respond_to do |format|
      if @school
        #@forums = @school.forums
        @status = Status.new
        
        format.html {
          # se usuário não logado ou escola é privada e o cara não está inscrito nela, mostrar perfil privado
         unless current_user.has_access_to @school
            render 'show_private' and return
          else
            render 'show' and return
          end
          # show.html.erb
        }
        format.xml  { render :xml => @school }
      else
        format.html { 
        flash[:error] = "A escola \"" + params[:id] + "\" não existe ou não está cadastrada no Redu."
        redirect_to schools_path
        }
      end
      
    end
  end
  
  def cancel
     session[:school_step] = session[:school_params] = nil
    redirect_to schools_path
  end
  
  # GET /schools/new
  # GET /schools/new.xml
  def new
     session[:school_params] ||= {}
     @school = School.new(session[:school_params])
     @school.current_step = session[:school_step]
    
#    @school = School.new
#    
#    respond_to do |format|
#      format.html # new.html.erb
#      format.xml  { render :xml => @school }
#    end
  end
  
  # GET /schools/1/edit
  def edit
    @school = School.find(params[:id])
  end
  
  # POST /schools
  # POST /schools.xml
  def create
    
    session[:school_params].deep_merge!(params[:school]) if params[:school]
  @school = School.new(session[:school_params])
  @school.owner = current_user
  @school.current_step = session[:school_step]
  if @school.valid?
    if params[:back_button]
      @school.previous_step
    elsif @school.last_step?
      @school.save if @school.all_valid?
    else
      @school.next_step
    end
    session[:school_step] = @school.current_step
  end
  if @school.new_record?
    render "new"
  else
    UserSchoolAssociation.create({:user => current_user, :school => @school, :status => "approved", :role_id => 4}) #:role => Role[:school_admin]
    session[:school_step] = session[:school_params] = nil
    flash[:notice] = "Rede criada!"
    redirect_to @school
  end

    
    
#    @school = School.new(params[:school])
#    
#    @school.owner = current_user
#    
#    respond_to do |format|
#      if @school.save!
#        
#        UserSchoolAssociation.create({:user => current_user, :school => @school, :status => "approved", :role => Role[:school_admin]})
#        
#        flash[:notice] = 'A rede foi criada com sucesso!'
#        format.html { redirect_to(@school) }
#        format.xml  { render :xml => @school, :status => :created, :location => @school }
#      else
#        format.html { render :action => "new" }
#        format.xml  { render :xml => @school.errors, :status => :unprocessable_entity }
#      end
#    end
  end
  
  # PUT /schools/1
  # PUT /schools/1.xml
  def update
    unless params[:only_image]
      params[:school][:category_ids] ||= []
      params[:school][:audience_ids] ||= []
    end
    @school = School.find(params[:id])
    
    respond_to do |format|
      if @school.update_attributes(params[:school])
        flash[:notice] = 'A escola foi atualizada com sucesso!'
        format.html { redirect_to(@school) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @school.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  # DELETE /schools/1
  # DELETE /schools/1.xml
  def destroy
    @school = School.find(params[:id])
    @school.destroy
    
    respond_to do |format|
      format.html { redirect_to(schools_url) }
      format.xml  { head :ok }
    end
  end

protected

def can_be_owner_required
   @school = School.find(params[:id])
   
   current_user.can_be_owner?(@school) ? true : access_denied
end

end
