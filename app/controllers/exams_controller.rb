class ExamsController < BaseController
=begin  
  @@quiz = [
  { :question => "What's the square root of 9?",
        :options => ['2','3','4'],
        :answer => "3" },
  { :question => "What's the square root of 4?",
        :options => ['16','2','8'],
        :answer => '16' },
  { :question => "How many feet in a mile?",
        :options => ['90','130','5,280', '23,890'],
        :answer => '5,280' },
  { :question => "What's the total area of irrigated land in Nepal?",
        :options => ['742 sq km','11,350 sq km','5,000 sq km','none of the above'],
        :answer => '11,350 sq km' },
  ] 
=end  

# COLOCAR QUIZ (EXAM) NA SESSAO OU FAZER REQUESTS AO BD A CADA VEZ
# colocar array de ids de questao na sessao?

  #@@quiz = nil
  
  def answer
    if params[:first]
      reset_session
    end
    session[:exam] ||= Exam.find(params[:id])
    
    if session[:question_index].nil?
      session[:question_index] = 0
    end
    @step =  session[:exam].questions[session[:question_index]]
    @step
  end
  
  def check
    session[:correct] ||= 0
    
    @theanswer = params[:answer]
    @therealanswer = session[:exam].questions[session[:question_index]].answer_id
    
    if @theanswer.to_i == @therealanswer
      session[:correct] += 1
    end
    session[:question_index] += 1
    @step = session[:exam].questions[session[:question_index]]
    if @step.nil?
      redirect_to :action => "results", :id => params[:id]
    else
      redirect_to :action => "answer", :id => params[:id]
    end
  end
  
  def results
    @correct = session[:correct]
    @possible = session[:exam].questions.length
    @exam = params[:id]
    
    session[:question_index] = nil
    session[:correct] = nil
  end
  
  def start_over
    
    reset_session
    
    redirect_to :action => "answer" , :id => params[:id]
  end
  
  def reset_session
    session[:question_index] = nil
    session[:correct] = nil
    session[:exam] = nil
  end
  
  
=begin
  def answer
    @exam = session[:exam]
    
    if session[:current_question]  <  @exam.questions.length  
        session[:current_question] = session[:current_question] + 1
    else
        flash[:notice] = 'fim do exame'
        redirect_to(@exam)
    end
    
    @next_question = @exam.questions[session[:current_question]]
    
  end
 
  
  def take
    @exam = Exam.find(params[:id])
   # @exam.current_question = 0
   session[:current_question] = 0
    
    session[:exam] = @exam
    
     @next_question = @exam.questions[session[:current_question]]
    
    render  :action => :answer
   # redirect_to(:controller => :questions, :action => :answer, :id =>@next_question)
    
=begin    
    @exam.questions.each do |question|

    end
 
  end
=end 






  # GET /exams
  # GET /exams.xml
  def index
    @exams = Exam.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @exams }
    end
  end
  # GET /exams/1
  # GET /exams/1.xml
  def show
    @exam = Exam.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @exam }
    end
  end

  # GET /exams/new
  # GET /exams/new.xml
  def new
    @exam = Exam.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @exam }
    end
  end

  # GET /exams/1/edit
  def edit
    @exam = Exam.find(params[:id])
  end

  # POST /exams
  # POST /exams.xml
  def create
    @exam = Exam.new(params[:exam])
   # @exam.author = current_user
    
    @questions =  params[:questions]
    
    @questions.each do |question|
      @exam.questions << Question.find(question.to_i)
    end

    respond_to do |format|
      if @exam.save
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
    @exam.destroy

    respond_to do |format|
      format.html { redirect_to(exams_url) }
      format.xml  { head :ok }
    end
  end
end
