class ExamsController < BaseController
  layout 'new_application'
  
  before_filter :login_required, :except => [:index]
  uses_tiny_mce(:options => AppConfig.question_mce_options, :only => [:new, :edit, :create])
  
  
  def publish_score
    ExamUser.update(params[:exam_user_id], :public => params[:public])
    head :ok
  end
  
  
  
  # listagem de exames favoritos
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
  
  # reponder exame  
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
      if params[:q_index] == 'i' #instrucoes
        @show_i = true
        @has_next = true
        respond_to do |format|
          format.js
        end
        return
      elsif params[:q_index] == '-1' #anterior
        session[:question_index] -= 1 if session[:question_index] > 0
      else #proximo / pular para
        session[:question_index] = params[:q_index].to_i
      end
    end
    
    
    @step =  session[:exam].questions[session[:question_index]]
    @prev_step =  session[:exam].questions[session[:prev_index]] if session[:question_index] != session[:prev_index]
    
    @has_next = (session[:question_index] < (session[:exam].questions.length - 1)) ? true : false
    @has_prev = (session[:question_index] > 0)
    
    
    @theanswer = params[:answer]
    
    if @theanswer and @prev_step #TODO aceitar questoes em branco
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
  
  
  def results
    #TODO colocar :select => "DISTINCT(user_id)"
    @ranking = ExamUser.all( :conditions => ["exam_id = ? AND public = ?",session[:exam].id, true], :include => :user, :order => "correct_count DESC, time ASC", :limit => 10)
    
    @exam = session[:exam]
    @answers = session[:answers]
    @correct = 0
    @corrects = Array.new
    @time = params[:chrono].to_i
    
    @alternative_letters = {} 
    letters = ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j']
    
    
    @exam.questions.each_with_index do |question, k|
    
      if session[:answers][question.id].to_i == question.answer.id
        @corrects << question
        @correct += 1
      end
      
      question.alternatives.each_with_index do |alternative, l| #TODO dá pra otimizar aqui,isso nao eh muito necessario
        @alternative_letters[alternative.id] = letters[l]
      end

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
  
    # revisar questão no resultado do exame
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
  
  
  
  def rst_session
    session[:prev_index] = 0
    session[:question_index] = 0
    session[:correct] = nil
    session[:exam] = nil
    session[:answers] = Hash.new
    session[:corrects] = nil
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
        
        question = @exam.questions.build
        #4.times { question.alternatives.build }
        
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
#        @exam.questions.clear
#        
#        @questions =  params[:questions]
#        
#        if @questions
#          for question in @questions
#            
#            @exam.questions << Question.find(question.to_i) # TODO performance
#          end
#        end
        
        
        
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
      
      @exam.published = true # se o usuário completou os 3 passos então o curso está publicado
      
      if params[:post_to]
        SchoolAsset.create({:asset_type => "Exam", :asset_id => @exam.id, :school_id => params[:post_to].to_i})
      end
      
      respond_to do |format|
        
        if @exam.update_attributes(params[:exam])
          
          # remove exame da sessao
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
  
  
  
  def new_question
    
    #save_draft :id => params[:id], :exam => params[:exam], :hide => true
    @edit = false
    redirect_to :controller => :questions, :action => :new #, :exam_id => params[:id]
  end
  
  
  def questions_database
    
    @questions = Question.paginate(:all, :include=> :author, :conditions => ['public = ?', true],
    :page => params[:page], :order => 'created_at DESC', :per_page => 10)
    
    
    respond_to do |format|
      format.js
    end
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
          page << " jQuery('#spinner_" +@question.id.to_s+"').hide()"
          flash[:notice] = 'Questão adicionada'
          page.reload_flash
        end
      end    
    end
    
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
  
  
  
  
  def sort_question 
    # TODO esse método não faz nada! Simplesmente alterando a posicao de cada questão no formulario,
    # altera igualmente o array de questoes que vai pra action e atualiza o modelo de exames
    
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
