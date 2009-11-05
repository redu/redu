class SubjectsController < BaseController
  
  
  #As informações do fórum precisam ser dadas na view, como relacionar haml com html?
  def create_forum
    
    @subject = Subject.find(params[:id])
    @forum = Forum.new
    
    if @subject
      
      @subject.forums << @forum
    
      if @subject.save
          flash[:notice] = 'Fórum adicionado.'
      else
          flash[:error] = 'Algum problema aconteceu!'
      end
    
    else
      flash[:error] = 'Disciplina inválida.'
    end
    
    respond_to do |format|
      format.html { redirect_to(@subject) }
    end
    
  end
  
  
  #Associar usuário à disciplina 
  def add_user
    
    @subject = Subject.find(params[:id])
   # @user = User.find(params[:user_id])  # TODO precisa mesmo recuperar o usuário no bd?
    @user = current_user
    puts params[:user_key]
    
    @user_subject_association = UserSubjectAssociation.new(:user_id => @user.id, :subject_id => @subject.id)  
    
    if @user_subject_association
      
     #if @user_subject_association.access_key.expiration_date.to_time < Time.now # verifica a data da validade da chave
        
        #if @subject &&  @user_subject_association.subject == @subject
          
         # if @user && @user_subject_association.user # cada chave só poderá ser usada uma vez, sem troca de aluno
            
            
           # @user_subject_association.user = @user
            
            if @user_subject_association.save
              flash[:notice] = 'Usuário associado à disciplina!'
            else 
              flash[:notice] = 'Associação à disciplina falhou'
            end
        #  else 
       #     flash[:notice] = 'Essa chave já está em uso'
       #   end
     #   else
     #     flash[:notice] = 'Essa chave pertence à outra disciplina'
    #    end
    # else
     #   flash[:notice] = 'O prazo de validade desta chave expirou. Contate o administrador da sua escola.'
      #end
    else
     flash[:notice] = 'Chave inválida'
   end
    
    
    respond_to do |format|
      format.html { redirect_to(@subject) }
    end
    
  end
  
  # Lista todas as aulas existentes para relacionar com
  def list_courses
    @courses = Course.all
    @subject = params[:id]
  end
  
  # Lista todos os recursos existentes para relacionar com
  def list_resources
    @resources = Resource.all
    @subject = params[:id]
  end
  
  # Método que compara o nome da aula escrita com todas as aulas
  def name_compare
    Course.all(:conditions => [":name == ?", params[:course]])
  end
  
  # Adiciona aula(s) à disciplina associada.
  def add_course
    
    @selected_courses = params[:course][:id]
    puts @selected_courses
    
    @subject = Subject.find(params[:id])
    
    if @subject
       @selected_courses.each do |c| 
        @course = Course.find(c)
        @subject.courses << @course
      end
      
       if @subject.save
          flash[:notice] = 'Aula(s) adicionada(s).'
        else
          flash[:error] = 'Algum problema aconteceu!'
        end
      
    else
      flash[:error] = 'Disciplina inválida.'
    end  
    
    respond_to do |format|
      format.html { redirect_to(@subject) }
    end
  
end

  def add_resource
    
    @selected_resources = params[:resource][:id]
    puts @selected_resources
    
    @subject = Subject.find(params[:id])
    
    if @subject
       @selected_resources.each do |c| 
        @resource = Resource.find(c)
        @subject.resources << @resource
      end
      
       if @subject.save
          flash[:notice] = 'Recurso(s) adicionada(s).'
        else
          flash[:error] = 'Algum problema aconteceu!'
        end
    else
      flash[:error] = 'Disciplina inválida.'
    end  
    
    respond_to do |format|
      format.html { redirect_to(@subject) }
    end
  end


  
 # def self.find_subjects
    #unless
    #   subject[:name]              
   # end
 #   find(:all)
  #end
  
  # GET /subjects
  # GET /subjects.xml
  
  
  def index
    @subjects = Subject.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @subjects }
    end
  end

  # GET /subjects/1
  # GET /subjects/1.xml
  def show
    @subject = Subject.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @subject }
    end
  end

  # GET /subjects/new
  # GET /subjects/new.xml
  def new
    @subject = Subject.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @subject }
    end
  end

  # GET /subjects/1/edit
  def edit
    @subject = Subject.find(params[:id])
  end

  
  # POST /subjects
  # POST /subjects.xml
  def create
    @subject = Subject.new(params[:subject])

    respond_to do |format|
      if @subject.save
        flash[:notice] = 'Disciplina foi criada com sucesso.'
        format.html { redirect_to(@subject) }
        format.xml  { render :xml => @subject, :status => :created, :location => @subject }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @subject.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /subjects/1
  # PUT /subjects/1.xml
  def update
    @subject = Subject.find(params[:id])

    respond_to do |format|
      if @subject.update_attributes(params[:subject])
        flash[:notice] = 'Subject was successfully updated.'
        format.html { redirect_to(@subject) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @subject.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /subjects/1
  # DELETE /subjects/1.xml
  def destroy
    @subject = Subject.find(params[:id])
    @subject.destroy

    respond_to do |format|
      format.html { redirect_to(subjects_url) }
      format.xml  { head :ok }
    end
  end
end
