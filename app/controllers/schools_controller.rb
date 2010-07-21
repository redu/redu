class SchoolsController < BaseController
  layout 'new_application'
  before_filter :login_required,  :except => [:join, :unjoin, :member]
  # before_filter :admin_required,  :only => [:new, :create]
  
  def vote
    @school = School.find(params[:id])
    current_user.vote(@school, params[:like])
    head :ok
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
  
  def pending_courses 
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
  
  
  def pending_members 
    @school = School.find(params[:id])
    @pending_members = UserSchoolAssociation.paginate(:conditions => ["status like 'pending' AND school_id = ?", params[:id]], 
      :page => params[:page], 
      :order => 'updated_at DESC', 
      :per_page => AppConfig.items_per_page)
    
    respond_to do |format|
      format.html #{ render :action => "my" }
      #format.xml  { render :xml => @courses }
    end
    
  end
  
  
 def moderate_members
   @approve_ids = params[:approve]#.collect{|c| c.to_i}
   @disapprove_ids = params[:disapprove]
   
   UserSchoolAssociation.update_all( "status = 'approved'", ["id IN (?)", @approve_ids.join(',') ]) if @approve_ids
   UserSchoolAssociation.update_all( "status = 'disaproved'",["id IN (?)", @approve_ids.join(',') ]) if @disapprove_ids
   
   flash[:notice] = "Alterações salvas!"
   
   redirect_to pending_members_school_path(params[:id])
   
   
 end
  
  
  
  
  
  def associate
    @school = School.find(params[:id])
    @user = User.find(params[:user_id])  # TODO precisa mesmo recuperar o usuário no bd?
    puts params[:user_key]
    
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
  
  
  def member
    @schools = current_user.schools
    
  end
  
  def owner
    #@user_school_association_array = UserSchoolAssociation.find(:all, :conditions => ["user_id = ? AND role_id = ?", current_user.id, 4])
   @schools = current_user.schools_owned
   
   
   
  end
  
  
  def members
    @school = School.find(params[:id]) #TODO duas queries que poderiam ser apenas 1
    
     @members = @school.users.paginate(  #optei por .users ao inves de .students
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
    @schools = School.all
    
     @popular_tags = School.tag_counts
    
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @schools }
    end
  end
  
  # GET /schools/1
  # GET /schools/1.xml
  def show
    @school = School.find(params[:id])
     if @school.removed
      redirect_to removed_page_path and return
    end
    
    @courses = @school.courses.paginate(:conditions => 
      ["published = 1"], 
      :include => :owner, 
      :page => params[:page], 
      :order => 'updated_at DESC', 
      :per_page => AppConfig.items_per_page)
      
    respond_to do |format|
      if @school
        @forums = @school.forums
        @status = Status.new
        
        format.html {
          # se usuário não logado ou escola é privada e o cara não está inscrito nela, mostrar perfil privado
          if not current_user or (not @school.public and not @school.users.include? current_user) 
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
    UserSchoolAssociation.create({:user => current_user, :school => @school, :status => "approved", :role => Role[:school_admin]})
    session[:school_step] = session[:school_params] = nil
    flash[:notice] = "School saved!"
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
end
