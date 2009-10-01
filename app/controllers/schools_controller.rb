class SchoolsController < BaseController
  #before_filter :login_required,  :except => [:index, :new, :create]
  before_filter :admin_required,  :only => [:new, :create]
 
 ##  Admin actions  
  def new_school_admin
    @user_school_association = UserSchoolAssociation.new
    
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @school }
    end
  end
  
  def create_school_admin
    
    user = params[:user]
    school = params[:id]
    
    @user_school_association = UserSchoolAssociation.new
    
    #@school = School.new(params[:school])

    respond_to do |format|
      if @user_school_association.save
        flash[:notice] = 'Administrador da escola criado'
        format.html { redirect_to(@school) }
        format.xml  { render :xml => @school, :status => :created, :location => @school }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @school.errors, :status => :unprocessable_entity }
      end
    end
    
  end


  ### School Admin actions
  def invalidate_keys(access_key) # 'troca' um conjunto de chaves
    
  end

  def index_school_keys(school)
    @access_keys = AccessKey.all(:conditions => ['school_id = ?', school.id])

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @access_keys }
    end
  end
  

  def associate
      @school = School.find(params[:id])
      
      if !@school.students.include? current_user
       # @school.students << current_user
       @user_school_association = UserSchoolAssociation.new
       @user_school_association.user = current_user
       @user_school_association.school = @school
       @user_school_association.role = Role[:student]
     end
     
     respond_to do |format|
        if @user_school_association.save!
          flash[:notice] = 'Usuário associado à escola!' #:the_friendship_was_accepted.l
        else
         flash[:notice] = 'Associação à escola falhou'
       end
        format.html { render :action => "show" }
      end
      
    end


   # GET /schools
  # GET /schools.xml
  def index
    @schools = School.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @schools }
    end
  end

  # GET /schools/1
  # GET /schools/1.xml
  def show
    @school = School.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @school }
    end
  end

  # GET /schools/new
  # GET /schools/new.xml
  def new
    @school = School.new

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
    
    #nao eh necessario pois ja temos verificacao no modelo
    #if !params[:school][:name] || params[:school][:name].empty?
    #  flash[:error] = 'Name não pode ser vazio'
    #  redirect_to(@school)
    #end
    


    respond_to do |format|
      if @school.save
        flash[:notice] = 'School was successfully created.'
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
        flash[:notice] = 'School was successfully updated.'
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
