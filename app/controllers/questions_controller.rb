class QuestionsController < BaseController
   layout 'new_application'
   
  before_filter :login_required, :except => [:index]
  
  uses_tiny_mce(:options => AppConfig.simple_mce_options, :only => [:new, :edit])

#question_mce_options
  def add
    @exam_type = params[:exam_type]
    
   # @questions = Question.all(:conditions => ['public = ?', 1])
    
    @questions = Question.paginate(:all,      :conditions => ['public = ?', true],
    :page => params[:page], :order => 'created_at DESC', :per_page => 10)
    
    
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @questions }
    end
  end
  
  
  def sort
    
  end

  def search
    
    @questions = Question.find(:all, :conditions => ["statement LIKE ?", "%" + params[:query] + "%"])
    #, :conditions => ["statement LIKE '%?%'", params[:query]]
    
    respond_to do |format|
      format.js do
          render :update do |page| 
            page.replace_html 'local_search_results', 
           :partial => "questions/list", :object => @questions
           # :partial => "questions/list_item", :collection => @products, :as => :item 
            #page.insert_html :bottom, "questions", :partial => 'questions/question_show', :object => @question
            #page.visual_effect :highlight, "question_#{@question.id}" 
          end
      end
    end
  end
  
  # GET /questions
  # GET /questions.xml
  def index # listagem do banco de questoes
    
    if params[:user_id]
      @questions = Question.all(:conditions => ['author_id = ?', params[:user_id]])

      respond_to do |format|
        format.html  { render "my_questions" }
        format.xml  { render :xml => @questions }
      end
    else
    
      @questions = Question.all(:conditions => ['public = ?', 1])
  
      respond_to do |format|
        format.html # index.html.erb
        format.xml  { render :xml => @questions }
      end
    end
  end

  def show
    
    @question = Question.find(params[:id].to_i)
    
    
     respond_to do |format|
        format.js
    end
  end

  # GET /questions/1
  # GET /questions/1.xml
=begin
  def show
    @question = Question.find(params[:id])

    render :show , :layout => false

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @question }
    end
end
=end

  # GET /questions/new
  # GET /questions/new.xml
  def new
    
    @exam_type = params[:exam_type]
    @edit = false
    @question = Question.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @question }
    end
  end

  # GET /questions/1/edit
  def edit
    @question = Question.find(params[:id])
  end

  # POST /questions
  # POST /questions.xml
  def create
    
    @question = Question.new(params[:question])
    @question.author = current_user
    @alternatives = params[:alternative][:statement]
    
    @alternatives.each do |alternative|
      if !alternative.empty?
        @question.alternatives << Alternative.new(:statement => alternative)
      end
    end
    
    respond_to do |format|
      if @question.save! && params[:answer]
        # TODO fazer verificação disto (é sempre na ordem correta?)
        @answer = @question.alternatives[params[:answer].to_i]
        @question.update_attribute(:answer, @answer)
        
        if session[:exam_id]
          
          @exam = Exam.find(session[:exam_id])
          
          @exam.questions << @question
          @exam.update_attribute(:questions, @exam.questions)
          
        end
        
        flash[:notice] = 'A questão foi criada e adicionada ao teste.'
        format.html { #redirect_to(@question) 
          redirect_to :controller => :exams, :action => :new, :step => '2', :exam_type => params[:exam_type] 
        }
        format.xml  { render :xml => @question, :status => :created, :location => @question }
=begin        
        format.js do
          responds_to_parent do
            render :update do |page| 
              page.insert_html :bottom, "questions", :partial => 'questions/question_show', :object => @question
              page.visual_effect :highlight, "question_#{@question.id}" 
            end
          end          
        end
=end
        
      else
       # flash[:error] = 'Um erro aconteceu ao salvar a questão.'
       
=begin        
        format.html { 
          redirect_to :controller => :exams, :action => :new
        }
=end       
        format.html { render :action => "new" }
        format.xml  { render :xml => @question.errors, :status => :unprocessable_entity }
        
=begin
        format.js do
          responds_to_parent do
            render :update do |page|
              # update the page with an error message
              flash[:notice] = 'Um erro aconteceu'
              page.reload_flash
              
            end
          end          
        end
=end
      end
    end
  end

  # PUT /questions/1
  # PUT /questions/1.xml
  def update
    @question = Question.find(params[:id])
    @alternatives = Array.new
    #@alternatives = params[:alternative][:statement].reject { |alternative| alternative.empty? }
    
    params[:alternative][:statement].each do |alternative|
      if !alternative.empty?
        @alternatives << Alternative.new(:statement => alternative)
      end
    end
    
    @question.alternatives = @alternatives

    respond_to do |format|
      if @question.update_attributes!(params[:question]) && params[:answer]
        # TODO fazer verificação disto (é sempre na ordem correta?)
        @answer = @question.alternatives[params[:answer].to_i]
        @question.update_attribute(:answer, @answer)
        
        if session[:exam_draft]
          session[:exam_draft].questions << @question
        end
        
         flash[:notice] = 'A questão foi atualizada com sucesso!'
        format.html { #redirect_to(@question) 
          redirect_to :controller => :exams, :action => :new, :step => '2', :exam_type => params[:exam_type] 
        }
        format.xml  { render :xml => @question, :status => :created, :location => @question }
        
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @question.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /questions/1
  # DELETE /questions/1.xml
  def destroy
    @question = Question.find(params[:id])
    @question.destroy

    respond_to do |format|
      format.html { redirect_to(questions_url) }
      format.xml  { head :ok }
    end
  end
end
