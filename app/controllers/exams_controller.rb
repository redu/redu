  class ExamsController < BaseController
  
  before_filter :login_required, :except => [:index]
  
  def show_favorites
    current_user.get_favorites
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
      reset_session
      
      @exam = Exam.find(params[:id])
      
       Log.log_activity(@exam, 'answer', current_user)
     
      
    end
    
    session[:exam] ||= @exam
    
    if session[:question_index].nil?
      session[:question_index] = 0
    elsif params[:q_index]
      session[:question_index] = params[:q_index].to_i
    end
    
    @has_next = (session[:question_index] < (session[:exam].questions.length - 1))
    
    @step =  session[:exam].questions[session[:question_index]]
    @step
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
      redirect_to :action => "answer", :id => params[:id]
    end
  end
  
  def results
    @exam = session[:exam]
    @correct = 0
    @corrects = Array.new
    
    for k in 0..(@exam.questions.length - 1)
      question = @exam.questions[k]
      correct_answer = question.answer.id
      
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
      
      if session[:answers][question.id].to_i == correct_answer
        @corrects << question
        @correct += 1
        
        if @competence
          @competence.correct_count += 1
        end
        
     end
     
     if @competence
       if @competence.new_record?
         @competence.save
       else
         @competence.update_attributes(:done_count => @competence.done_count, :correct_count => @competence.correct_count)
       end
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
    @exam_user.save
    
    #TODO performance?
    session[:corrects] = @corrects
    
    respond_to do |format|
            format.html 
            format.xml  { head :ok }
     end
  end
  
  def start_over
    
    reset_session
    
    redirect_to :action => "answer" , :id => params[:id]
  end
  
  def reset_session
    session[:question_index] = nil
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
  
  def discard_draft
    session[:exam_draft] = nil
    redirect_to exams_path
  end
  
  def new
    
    if request.get?
      @exam = session[:exam_draft] || Exam.new
    elsif params[:sbt_opt] == "1" # new question
      
      # @questions =  params[:questions]
      
=begin      
      @questions.each do |question|
        session[:exam_draft].questions << Question.find(question.to_i) # TODO performance
      end
=end
      
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
  
  def new_question
    
    #save_draft :id => params[:id], :exam => params[:exam], :hide => true
    
    redirect_to :controller => :questions, :action => :new#, :exam_id => params[:id]
  end
  
  def add_question
    @question = Question.find(params[:question_id], :include => :answer)
    
    if session[:exam_draft]
       session[:exam_draft].questions << @question
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
    
    respond_to do |format|
=begin      
      format.html {
        redirect_to :action => :new
      }
      format.xml  { render :xml => @exam }
=end
      format.js do
        render :update do |page|
          page.remove "question_" + params[:id]
          flash[:notice] = "Questão removida do exame"
          page.reload_flash
          # page.remove "question_#{@question.id}"  
        end    
      end
  end
  end
     
  def add_resource
    @resource = Resource.find(params[:resource_id])
    
    if session[:exam_draft]
      session[:exam_draft].resources << @resource
    end
    
    respond_to do |format|
      format.html do
        render :update do |page|
          flash[:notice] = 'Material adicionada'
          page.remove "resource_" + params[:resource_id]
          page.reload_flash
        end
      end 
      format.js do
        render :update do |page|
          flash[:notice] = 'Material adicionada'
          page.remove "resource_" + params[:resource_id]
          page.reload_flash
        end
      end    
    end
    
  end
  
     
     
  
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
    
    @exams = Exam.find(:all, :conditions => ["name LIKE ?", "%" + params[:query] + "%"])
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
    @sort_by = params[:sort_by]
    #@order = params[:order]
    @exams = get_query(params[:sort_by], params[:page]) 
    
    
    #@exams = Exam.paginate({
    #:conditions => ['published = ?', true] + sort, 
    #:include => :owner, 
    #:page => params[:page], 
    #:order => 'updated_at DESC', 
    #:per_page => AppConfig.items_per_page})
    
    @tags = Exam.tag_counts
    
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @exams }
      
    end
  end
  
  
  
  
   ###########################################################################
  # GET /exams/1
  # GET /exams/1.xml
  def show
    @exam = Exam.find(params[:id])

    
    #thepoints = AppConfig.points['show_exam']
    #new_score = current_user.score + thepoints
    #current_user.score = new_score
    #current_user.save

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

  # PUT /exams/1
  # PUT /exams/1.xml
  def update
    @exam = Exam.find(params[:id])
    puts 'update actoin!!!!' 

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
