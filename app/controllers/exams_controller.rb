class ExamsController < BaseController
  layout 'new_application'
  
  before_filter :login_required, :except => [:index]
  
  uses_tiny_mce(:options => AppConfig.simple_mce_options, :only => [:new, :edit, :create])
  
  def favorites
    
    if params[:from] == 'favorites'
      @taskbar = "favorites/taskbar"
    else
      @taskbar = "exams/taskbar_index"
    end
    
    @exams = Exam.paginate(:all, 
    :joins => :favorites,
    :conditions => ["favorites.favoritable_type = 'Exam' AND favorites.user_id = ? AND exams.id = favorites.favoritable_id", current_user.id], 
    :page => params[:page], :order => 'created_at DESC', :per_page => AppConfig.items_per_page)
    
    
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @exams }
    end
  end
  
  

  def review
    if session[:question_index].nil?
      session[:question_index] = 0
    elsif params[:q_index]
      session[:question_index] = params[:q_index].to_i
    end
    
    @has_next = (session[:question_index] < (session[:exam].questions.length - 1))
    
    @step =  session[:exam].questions[session[:question_index]]
  
     render :action => :results unless @step
    
  end
  
  
  def answer
    
    
        if params[:first]
          rst_session
          
          @exam = Exam.find(params[:id])
           # Só para efeitos de teste. O objeto school vai ser passado na criação das aulas quando estiver
      		# dentro de uma rede.
      		#@school = School.find(:first, :conditions => ["owner = ?", current_user.id])
      		 Log.log_activity(@exam, 'answer', current_user, @school)
     
        end
        
       # initialize session variables
        session[:exam] ||= @exam
        session[:question_index] ||= 0
        session[:prev_index] ||= 0
        session[:correct] ||= 0
        
        # if user selected a question to show
        if params[:q_index]
          session[:question_index] = params[:q_index].to_i
        end
        
       
        
        
        @step =  session[:exam].questions[session[:question_index]]
        @prev_step =  session[:exam].questions[session[:prev_index]] if session[:question_index] != session[:prev_index]
        
        @has_next = (session[:question_index] < (session[:exam].questions.length - 1)) ? true : false
        @has_prev = (session[:question_index] > 0)
        
        
        @theanswer = params[:answer]
        
        if @theanswer and @prev_step
            session[:answers][@prev_step.id] = @theanswer
        end
        
       # if @theanswer.to_i == @therealanswer
       #   session[:correct] += 1
       # end
       
       session[:prev_index] = session[:question_index]
       session[:question_index] += 1
       
        if @step.nil?
          redirect_to :action => "results", :id => params[:id], :chrono => params[:chrono]
        else
          respond_to do |format|
                format.js
                format.html
          end
          
        end
    end
  
  def check
    session[:correct] ||= 0
    
    @thequestion = session[:exam].questions[session[:question_index]]
    @has_next = (session[:question_index] < (session[:exam].questions.length - 1))
    
    @theanswer = params[:answer]
    
    if @theanswer 
        session[:answers][@thequestion.id] = @theanswer
    end
    
   # if @theanswer.to_i == @therealanswer
   #   session[:correct] += 1
   # end
   
   puts params[:chrono]
   
    session[:question_index] += 1
    @step = session[:exam].questions[session[:question_index]]
    if @step.nil?
      redirect_to :action => "results", :id => params[:id]
    else
      respond_to do |format|
            format.html {redirect_to :action => "answer", :id => params[:id]}
            format.js
      end
      
    end
  end
  
  def results
    @exam = session[:exam]
    @answers = session[:answers]
    @correct = 0
    @corrects = Array.new
    @time = params[:chrono].to_i

    for k in 0..(@exam.questions.length - 1)
      question = @exam.questions[k]
      correct_answer = question.answer.id
      
=begin     
    if question.category
          @competence = UserCompetence.first(:conditions => ["user_id = ? AND skill_id = ?", current_user.id, question.category.id])
        
          if @competence#@idx
            @competence.done_count += 1
          else
           @competence = UserCompetence.new
           @competence.skill = question.category
           @competence.user = current_user
           @competence.done_count += 1
          end
      end
=end      
      if session[:answers][question.id].to_i == correct_answer
        @corrects << question
        @correct += 1
        
        if @competence
          @competence.correct_count += 1
        end
        
     end

=begin
     if @competence
       if @competence.new_record?
         @competence.save
       else
         @competence.update_attributes(:done_count => @competence.done_count, :correct_count => @competence.correct_count)
       end
     end
=end
    end
    
    # Atualiza contadores do exame
    @exam.update_attributes({:done_count => @exam.done_count + 1,
    :total_correct => @exam.total_correct + @correct })
    
    # Adiciona no histórico do usuário/exame
    @exam_user = ExamUser.new
    @exam_user.user = current_user
    @exam_user.exam = @exam
    @exam_user.done_at = Time.now
    @exam_user.correct_count = @correct
    @exam_user.time = @time
    @exam_user.save
    
    #TODO performance?
    session[:corrects] = @corrects
    respond_to do |format|
            format.html 
            format.xml  { head :ok }
     end
  end
  
  def review_question
    
    @exam = session[:exam]
    
    @question_index = @exam.get_question(params[:question_id].to_i)
    
    @question = @question_index[0] if @question_index
    @index = @question_index[1] if @question_index
    
    @answer = session[:answers][@question.id].to_i
    
    
     respond_to do |format|
        format.js
    end
  end
  
  def start_over
    
    reset_session
    
    redirect_to :action => "answer" , :id => params[:id]
  end
  
  def rst_session
    session[:prev_index] = 0
    session[:question_index] = 0
    session[:correct] = nil
    session[:exam] = nil
    session[:answers] = Hash.new
    session[:corrects] = nil
  end


 ###########################################################################

  

  def save_draft
    
    @exam = Exam.new(params[:exam])
    # @exam.author = current_user
    
    @questions =  params[:questions]
    
    @questions.each do |question|
      @exam.questions << Question.find(question.to_i)
    end
    
    if !params[:hide]

      if @exam.save
        flash[:notice] = 'Exam was successfully created.'
      else
        flash[:error] = 'Exam could not be created.'
      end
         head :created 

    end
    
  end
 ###########################################################################
  def save_dft
     session[:exam_draft] = Exam.new(params[:exam])
      
      if  params[:questions]
        # session[:exam_draft].questions_ids = params[:questions].map(&:to_i) 
        params[:questions].each do |question|
          session[:exam_draft].questions << Question.find(question.to_i) # TODO performance
        end
      end
  end
  

def cancel
   Exam.find(session[:exam_id]).destroy
   session[:exam_id] = nil
   flash[:notice] = "Criação de exame cancelada."
   redirect_to exams_path
end
  
  def new
    if params[:school_id]
     @school = School.find(params[:school_id]) 
    end
    
    case params[:step]
      when "2"
        
        if params[:exam_type] == 'simple'
        
          @exam = Exam.find(session[:exam_id])
        
          @exam.enable_validation_group :step2
          @edit = false
          render "step2_simple" and return
        
        elsif params[:exam_type] == 'formative'
         
        
        elsif params[:exam_type] == 'quiz'
         
        
        end
        
      when "3"
        @exam = Exam.find(session[:exam_id])
        @schools = current_user.schools
        
        @exam_type = params[:exam_type]
        
         @exam.enable_validation_group :step3
        render "step3" and return
        
      else # 1
     # session[:course_id] = nil
        if session[:exam_id]
          @exam = Exam.find(session[:exam_id])
        else
          @exam = Exam.new
        end
      
       
        render "step1" and return
    end
    
  
end


def create

    case params[:step]
      when "1"
          @exam = Exam.new(params[:exam])
          @exam.owner = current_user
          @exam.enable_validation_group :step1
          
          respond_to do |format|
            if @exam.save
              
              session[:exam_id] = @exam.id
              
              format.html { 
                redirect_to :action => :new , :exam_type => params[:exam_type], :step => "2", :school_id => params[:school_id]
              }
            else  
              format.html { render "step1" }
            end
          end
          
      
      when "2"
      
      if params[:exam_type] == 'simple'
        
        @exam = Exam.find(session[:exam_id])
        @exam.questions.clear
        
        @questions =  params[:questions]
        
        if @questions
          for question in @questions
          
            @exam.questions << Question.find(question.to_i) # TODO performance
          end
        end
        
        
        
        if params[:sbt_opt] == "0" # save exam
          
          @exam.enable_validation_group :step2
          
          respond_to do |format|
            
            if @exam.update_attributes(params[:exam])
              
              format.html do
                redirect_to :action => :new , :exam_type => params[:exam_type], :step => "3", :school_id => params[:school_id]
              end
              format.js do
                render :update do |page|
                   page << "jQuery('#save_info').html('Salvo em #{Time.now.utc}')"
                end
              end
            else  
              @edit = false
              format.html do
                render "step2_simple" 
              end
               format.js do
                  render :update do |page| 
                    page << "alert('Erro ao salvar. Tente novamente em alguns instantes.')"
                  end
                end
            end
          end
          
          
        elsif params[:sbt_opt] == "1" # new question
          
          @exam.update_attributes(params[:exam])
          
          redirect_to :controller => :questions, :action => :new, :exam_type => params[:exam_type], :school_id => params[:school_id]
          
        elsif params[:sbt_opt] == "2" # add question  
          #save_dft
          @exam.update_attributes(params[:exam])
          redirect_to :controller => :questions, :action => :add, :exam_type => params[:exam_type], :school_id => params[:school_id]
          
        elsif params[:sbt_opt] == "3" # add resource  TODO mudar
          #save_dft
          @exam.update_attributes(params[:exam])
         # redirect_to :controller => :resources, :action => :add, :exam_type => params[:exam_type]
          
         elsif params[:sbt_opt] == "4" # edit question
          @exam.update_attributes(params[:exam])
          @exam_type = params[:exam_type]
          @question = Question.find(params[:opt_param])
          render "edit_question"
         # redirect_to :action => :edit_question, :exam_type => params[:exam_type]
        
          
        end
        
        
      elsif params[:exam_type] == 'formative'
        
      elsif params[:exam_type] == 'quiz'
        
      end
        
        ############# PASSO 3 ##############
      when "3"
        
       @exam = Exam.find(session[:exam_id])
        @exam.enable_validation_group :step3
        
      
      if params[:post_to]
        SchoolAsset.create({:asset_type => "Exam", :asset_id => @exam.id, :school_id => params[:post_to].to_i})
      end
      
      respond_to do |format|
        
        if @exam.update_attributes(params[:exam])
          
          #Log.log_activity(@course, 'create', current_user) # só aparece quando é aprovada
          # remover curso da sessao
          session[:exam_id] = nil
          
          flash[:notice] = 'O exame foi criado com sucesso! '
          format.html { 
            #redirect_to(@course)
            redirect_to @exam
          }
        else  
          format.html { render "step3" }
        end
        
      end
      
      
    end


end

  def unpublished_preview
  @exam = Exam.find(session[:exam_id])
  
  respond_to do |format|         
    format.html {render 'unpublished_preview_interactive'}
  end
end
  
  
=begin  
  def new
    
    if request.get?
      @exam = session[:exam_draft] || Exam.new
    elsif params[:sbt_opt] == "1" # new question
      
      # @questions =  params[:questions]
      
      #@questions.each do |question|
      #  session[:exam_draft].questions << Question.find(question.to_i) # TODO performance
      #end
      
      #params[:ids].map(&:to_i) 
      # @user.post_ids = your_post_ids
      #@user.post_ids = params[:ids].map(&:to_i) ?  
      
     save_dft
      redirect_to :controller => :questions, :action => :new
      
    elsif params[:sbt_opt] == "2" # add question  
      save_dft
      redirect_to :controller => :questions, :action => :add
      
    elsif params[:sbt_opt] == "3" # add resource  
      save_dft
      redirect_to :controller => :resources, :action => :add
      
      
    else # save / publish exam  
      
      if !params[:exam][:id].empty?
        # TODO redirecionar para actions correspondentes, esta muito codigo aqui!!!
        #redirect_to :action => :update, :id => params[:exam][:id], :exam => params[:exam]
        
        @exam = Exam.find(params[:exam][:id])

        @exam.questions.clear
        
        @questions =  params[:questions]
        
        @questions.each do |question|
          @exam.questions << Question.find(question.to_i) # TODO performance
        end
        
        if params[:sbt_opt] == "4" # publish exam
          @exam.published = true;
        end
        
        respond_to do |format|
          if @exam.update_attributes(params[:exam])
            flash[:notice] = 'Exam was successfully updated.'
            format.html { redirect_to exams_path }
            format.xml  { head :ok }
          else
            format.html { render :action => "edit" }
            format.xml  { render :xml => @exam.errors, :status => :unprocessable_entity }
          end
        end
        
      else
        
        @exam = Exam.new(params[:exam])
        @exam.owner_id = current_user
        
        @questions =  params[:questions]
        
        @questions.each do |question|
          @exam.questions << Question.find(question.to_i) # TODO performance
        end
        
         if params[:sbt_opt] == "4" # publish exam
          @exam.published = true;
        end
        
        respond_to do |format|
          if @exam.save # new exam
            flash[:notice] = 'Exam was successfully created.'
            format.html { render :action => "new" }
            format.xml  { render :xml => @exam, :status => :created, :location => @exam }
          else
            format.html { render :action => "new" }
            format.xml  { render :xml => @exam.errors, :status => :unprocessable_entity }
          end
        end
      end
    end
  end 

=end
  def new_question
    
    #save_draft :id => params[:id], :exam => params[:exam], :hide => true
    @edit = false
    redirect_to :controller => :questions, :action => :new #, :exam_id => params[:id]
  end
  
  def add_question
    @question = Question.find(params[:question_id], :include => [:answer, :alternatives])
    #TODO copiar questão
    
    #@q_copy = Question.create({:statement => @question.statement, :answer => @question.answer, :author => @question.author, :public => false, :justification => @question.justification, :alternatives => @question.alternatives.clone})

    @q_copy = @question.clone
    @q_copy.answer = @question.answer.clone
    @question.alternatives.each {|a| 
    @q_copy.alternatives << a.clone
    }
    #@q_copy.alternatives = @question.alternatives.clone
    @q_copy.public = 0
    @q_copy.save
    
     if session[:exam_id]
          
          @exam = Exam.find(session[:exam_id])
          
          @exam.questions << @q_copy
          @exam.update_attribute(:questions, @exam.questions)
          
      end
    
   
  respond_to do |format|
    format.html do
      render :update do |page|
        # update the page with an error message
        flash[:notice] = 'Questão adicionada'
        page.reload_flash
      end
    end # index.html.erb
    format.js do
      render :update do |page|
        # update the page with an error message
        flash[:notice] = 'Questão adicionada'
        page.reload_flash
      end
    end    
  end

=begin
   if request.xml_http_request?
      render :partial => "items_list", :layout => false
    end

   
   
    respond_to do |format|
       format.js do
        render :update do |page|
          page.remove "question_" + params[:id]  #question_39
          # page.remove "question_#{@question.id}"  
        end    
      end
    end
=end   
  end
  
  def remove_question
    
   # session[:exam_draft].questions.delete(Question.find(params[:id])) # TODO manter sincronizado, vale  a pena?
    
        if session[:exam_id]
          @exam = Exam.find(session[:exam_id])
          @exam.questions.delete(Question.find(params[:qid]))
          # @exam.update_attribute(:questions, @exam.questions)
        end

    respond_to do |format|

      format.js do
        render :update do |page|
          page.remove "question_" + params[:qid]
          flash[:notice] = "Questão removida do exame"
          page.reload_flash
          # page.remove "question_#{@question.id}"  
        end    
      end
  end
end


     
#  def add_resource
#    @resource = Resource.find(params[:resource_id])
#    
#    if session[:exam_draft]
#      session[:exam_draft].resources << @resource
#    end
#    
#    respond_to do |format|
#      format.html do
#        render :update do |page|
#          flash[:notice] = 'Material adicionado'
#          page.remove "resource_" + params[:resource_id]
#          page.reload_flash
#        end
#      end 
#      format.js do
#        render :update do |page|
#          flash[:notice] = 'Material adicionado'
#          page.remove "resource_" + params[:resource_id]
#          page.reload_flash
#        end
#      end    
#    end
#    
#  end
  
     
     
  
  def sort_question 
    # TODO esse método não faz nada! Simplesmente alterando a posicao de cada questão no formulario,
   # altera igualmente o array de questoes que vai pra action e atualiza o modelo de exames
    
    #puts params[:questions]
=begin    
    if session[:exam_draft].id
      
      @grocery_list = Exam.find(params[:id])
      @grocery_list.food_items.each do |food_item|
        food_item.position = params['grocery-list' ].index(food_item.id.to_s) + 1
        food_item.save
      end
    else # nao foi salvo ainda
  end
=end      
      
    # http://media.pragprog.com/titles/fr_rr/Sortable.pdf
    render :nothing => true
  end


 ###########################################################################
def search
    
    @exams = Exam.find_tagged_with(params[:query])
    @exams += Exam.find(:all, :conditions => ["name LIKE ?", "%" + params[:query] + "%"])
    #, :conditions => ["statement LIKE '%?%'", params[:query]]
    
    respond_to do |format|
      format.js do
          render :update do |page| 
            page.replace_html 'all_list', 
           :partial => 'exams/item', :collection => @exams, :as => :exam
            page.replace_html 'title_list', "Resultados para: \"#{params[:query]}\""
           # :partial => "questions/list_item", :collection => @products, :as => :item 
            #page.insert_html :bottom, "questions", :partial => 'questions/question_show', :object => @question
            #page.visual_effect :highlight, "question_#{@question.id}" 
          end
      end
    end
end



 ###########################################################################

 
  def published
   @exams = Exam.paginate(:conditions => ["owner_id = ? AND published = 1", params[:user_id]], :include => :owner, :page => params[:page], :order => 'updated_at DESC', :per_page => AppConfig.items_per_page)

     respond_to do |format|
        format.html #{ render :action => "my" }
        format.xml  { render :xml => @exams }
      end
  end

  def unpublished
    @exams = Exam.paginate(:conditions => ["owner_id = ? AND published = 0", current_user.id], :include => :owner, :page => params[:page], :order => 'updated_at DESC', :per_page => AppConfig.items_per_page)

     respond_to do |format|
        format.html #{ render :action => "my" }
        format.xml  { render :xml => @exams }
      end
  end
  
  def history
    #@exams = Exam.paginate(:conditions => ["owner_id = ? AND published = 0", current_user.id], :include => :owner, :page => params[:page], :order => 'updated_at DESC', :per_page => AppConfig.items_per_page)

    
    @exams = current_user.exam_history.paginate :page => params[:page], :order => 'updated_at DESC', :per_page => AppConfig.items_per_page
    #@user = current_user
    
    respond_to do |format|
      format.html #{ render :action => "exam_history" }
      format.xml  { render :xml => @exams }
    end
    
  end 
  
  def get_query(sort, page)
    
    case sort
      
    when '1' # Data
      @exams = Exam.paginate :conditions => ['published = ?', true], :include => :owner, :page => page, :order => 'created_at DESC', :per_page => AppConfig.items_per_page
    when '2' # Dificuldade
      @exams = Exam.paginate :conditions => ['published = ?', true], :include => :owner, :page => page, :order => 'level DESC', :per_page => AppConfig.items_per_page
    when '3' # Realizações
      @exams = Exam.paginate :conditions => ['published = ?', true], :include => :owner, :page => page, :order => 'done_count DESC', :per_page => AppConfig.items_per_page
    when '4' # Título
      @exams = Exam.paginate :conditions => ['published = ?', true], :include => :owner, :page => page, :order => 'name DESC', :per_page => AppConfig.items_per_page
      when '5' # Categoria
      @exams = Exam.paginate :conditions => ['published = ?', true], :include => :owner, :page => page, :order => 'name DESC', :per_page => AppConfig.items_per_page
      else
      @exams = Exam.paginate :conditions => ['published = ?', true], :include => :owner, :page => page, :order => 'created_at DESC', :per_page => AppConfig.items_per_page
    end
    
  end
  
  

  # GET /exams
  # GET /exams.xml
  def index
    
    if params[:user_id] # TODO garantir que é sempre login e nao id?
      @user = User.find_by_login(params[:user_id])
      @exams = @user.exams.paginate :page => params[:page], :per_page => AppConfig.items_per_page
      
      respond_to do |format|
        format.html { render :action => "user_exams"} 
        format.xml  { render :xml => @user.exams }
      end
    elsif params[:school_id]
        @school = School.find(params[:school_id])
      @exams = @school.exams.paginate( 
      :include => :owner, 
      :page => params[:page], 
      :order => 'updated_at DESC', 
      :per_page => AppConfig.items_per_page)
      respond_to do |format|
        format.js  { render 'index_school' }
      end
    else 
    
    @sort_by = params[:sort_by]
    #@order = params[:order]
    @exams = get_query(params[:sort_by], params[:page]) 
    
    
    #@exams = Exam.paginate({
    #:conditions => ['published = ?', true] + sort, 
    #:include => :owner, 
    #:page => params[:page], 
    #:order => 'updated_at DESC', 
    #:per_page => AppConfig.items_per_page})
    
    @popular_tags = Exam.tag_counts
    
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @exams }
      end
    end
  end
  
  
  
  
   ###########################################################################
  # GET /exams/1
  # GET /exams/1.xml
  def show
    @exam = Exam.find(params[:id])
    
     if @exam.removed
      redirect_to removed_page_path and return
    end
    
    Log.log_activity(@exam, 'create', current_user, @school)

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @exam }
    end
  end


  # GET /exams/1/edit
  def edit
    @exam = Exam.find(params[:id])
    
    render :action => :new
  end

  # POST /exams
  # POST /exams.xml
=begin
  def create
    @exam = session[:exam_draft] #Exam.new(params[:exam])
   @exam.owner = current_user
    
    @questions =  params[:questions]
    
    @questions.each do |question|
      @exam.questions << Question.find(question.to_i)
    end

    respond_to do |format|
      if @exam.save
        
        Log.log_activity(@exam, 'create', current_user)
        
        flash[:notice] = 'Exam was successfully created.'
        format.html { redirect_to(@exam) }
        format.xml  { render :xml => @exam, :status => :created, :location => @exam }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @exam.errors, :status => :unprocessable_entity }
      end
    end
  end
=end

  # PUT /exams/1
  # PUT /exams/1.xml
  def update
    @exam = Exam.find(params[:id])

    Log.log_activity(@exam, 'create', @exam.owner, @school)
    
    respond_to do |format|
      if @exam.update_attributes(params[:exam])
        flash[:notice] = 'Exam was successfully updated.'
        format.html { redirect_to(@exam) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @exam.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /exams/1
  # DELETE /exams/1.xml
  def destroy
    @exam = Exam.find(params[:id])
    
    if current_user == @exam.owner
    
       @exam.destroy
    end

    respond_to do |format|
      format.html { redirect_to(exams_url) }
      format.xml  { head :ok }
    end
  end
end
