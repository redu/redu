class SchoolsController < BaseController
  #before_filter :login_required,  :except => [:index, :new, :create]
  # before_filter :admin_required,  :only => [:new, :create]
  
  ##  Admin actions  
  def new_school_admin
    @user_school_association = UserSchoolAssociation.new
    
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @school }
    end
  end
  
  
  
  
=begin  
  def create_school_admin
    
    user_login = params[:login]
    user_key = params[:key]
    school_id = params[:id]
    
    # TODO validar se login valido, chave válida e desocupada, escola válida
    
    @user_school_association = UserSchoolAssociation.new
    
    @user_school_association.user = User.find_by_login(user_login)
    @user_school_association.school = School.find(school_id)
    @user_school_association.access_key = AccessKey

      if @user_school_association.save
        flash[:notice] = 'Administrador da escola criado'
      else
         flash[:error] = 'Administrador da escola não foi criado'
      end
      render :text => "OK" 
    
  end
=end
  
  ### School Admin actions
  def invalidate_keys(access_key) # 'troca' um conjunto de chaves
    
  end
  
  def join
    @school = School.find(params[:id])
    
    @association = UserSchoolAssociation.new
    @association.user = current_user
    @association.school = @school
    
    if @association.save
      flash[:notice] = "Você está participando da rede agora!"
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
  
  
  def students
    @school = School.find(params[:id])
    @students = @school.students
    
    #@users = User.recent.find(:all, :page => {:current => params[:page], :size => 100}, :conditions => cond.to_sql)
    
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @students }
    end
    
  end
  
  ###
  
  
  
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
    
    @courses = Course.find_by_sql("select c.* from courses c, school_assets sa where sa.asset_type = 'Course' and c.id = sa.asset_id and sa.school_id = '#{@school.id}'")
    #@courses = @school.assets#.collect{|asset| asset.asset_type = "Course"} #TODO limit
   
    
    @forums = @school.forums
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @school }
    end
  end
  
  # GET /schools/new
  # GET /schools/new.xml
  def new
    @school = School.new
    #@school.owner = current_user
    
    
    
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @school }
    end
  end
  
  # GET /schools/1/edit
  def edit
    @school = School.find(params[:id])
  end
  
  # POST /schools
  # POST /schools.xml
  def create
    @school = School.new(params[:school])
    
    @school.owner = current_user
    @school.admins << current_user
    
    respond_to do |format|
      if @school.save
        
        flash[:notice] = 'A escola foi atualizada com sucesso!'
        format.html { redirect_to(@school) }
        format.xml  { render :xml => @school, :status => :created, :location => @school }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @school.errors, :status => :unprocessable_entity }
      end
    end
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
