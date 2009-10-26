class QuestionsController < BaseController
  
  uses_tiny_mce(:options => AppConfig.question_mce_options, :only => [:new, :edit])

#question_mce_options
  def add
    @questions = Question.all(:conditions => ['public = ?', 1])

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @questions }
    end
  end
  
  
  def sort
    
  end

  def search
    
    @questions = Question.find(:all, :conditions => ["statement LIKE %?%", params[:query]])
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
    @questions = Question.all(:conditions => ['public = ?', 1])

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @questions }
    end
  end

  # GET /questions/1
  # GET /questions/1.xml
  def show
    @question = Question.find(params[:id])

    render :show , :layout => false
=begin
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @question }
    end
=end
  end

  # GET /questions/new
  # GET /questions/new.xml
  def new
    
   # @exam = 
    
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
    #@question.uploaded_data = params[:question]
=begin
    if params[:image] 
      puts 'tem imagem!!!'
      @image       = Image.new(params[:image])
      @question.image = @image
    end
=end    
    @alternatives = params[:alternative][:statement]
    
    @alternatives.each do |alternative|
     # QuestionExamAssociation
     if !alternative.empty?
        @question.alternatives << Alternative.new(:statement => alternative)
     end
    end
    
    respond_to do |format|
      if @question.save! && params[:answer]
       # TODO fazer verificação disto (é sempre na ordem correta?)
       @answer = @question.alternatives[params[:answer].to_i]
       @question.update_attribute(:answer, @answer)
       
       if session[:exam_draft]
       session[:exam_draft].questions << @question
       end
       
        flash[:notice] = 'Question was successfully created.'
        format.html { #redirect_to(@question) 
          redirect_to :controller => :exams, :action => :new_exam
        }
        format.xml  { render :xml => @question, :status => :created, :location => @question }
        format.js do
          responds_to_parent do
            render :update do |page| 
              page.insert_html :bottom, "questions", :partial => 'questions/question_show', :object => @question
              page.visual_effect :highlight, "question_#{@question.id}" 
            end
          end          
        end

      else
        
        format.html { 
         redirect_to :controller => :exams, :action => :new_exam
        }
        format.js do
        responds_to_parent do
          render :update do |page|
              # update the page with an error message
              flash[:notice] = 'Um erro aconteceu'
              page.reload_flash

          end
        end          
        end

        #format.html { render :action => "new" }
        #format.xml  { render :xml => @question.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /questions/1
  # PUT /questions/1.xml
  def update
    @question = Question.find(params[:id])

    respond_to do |format|
      if @question.update_attributes(params[:question])
        flash[:notice] = 'Question was successfully updated.'
        format.html { redirect_to :controller => :exams, :action => :new_exam }
        format.xml  { head :ok }
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
