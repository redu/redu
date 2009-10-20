class ExamsController < BaseController

  def take 
   rst
   @exam = Exam.find(params[:id])

   #array_ex = [[17, 53], [18, 57], [19, 61]]
   session[:questions] = @exam.questions.collect {|q| [q.id, q.answer_id ]  } 
   
   @nqid = session[:questions][0][0]
   
   redirect_to :action => :next_question, :id => @exam, :ci => 0, :nqid => @nqid
   
  end
  
  def next_question
    
    @eid = params[:id] # exam's id
    @qid = params[:qid] # current question's id
    @nqid = params[:nqid] # next question's id
    @theanswer = params[:answer] # current answer (alternative's id)
    
    if @theanswer 
        session[:answers][@qid] = @theanswer
    end
    
    if @nqid && !@nqid.eql?("") # prepare attributes for the next question
      
      @question = Question.find(@nqid)
      
      nextIndex = params[:ci].to_i + 1
      @next_qid =  session[:questions][nextIndex][0] if((nextIndex) < session[:questions].length) #primeiro valor
      
      @current_i = nextIndex
      # why the session cannot keep the index ? A.: because if the user hits 'back' in the browser, the questio    
    else # go to results
      
      redirect_to :action => :end_exam, :id => @eid
      
    end
    
    
  end
  
  def end_exam
    @exam = Exam.find(params[:id])
    @correct = 0
    @corrects = Array.new
    
    for k in 0..(@exam.questions.length - 1)
      question = session[:questions][k][0]
      correct_answer = session[:questions][k][1]
      
      if session[:answers][question.to_s].to_i == correct_answer
        @corrects << question
        @correct += 1
      end
      
    end
    
  end
  
  def rst
    session[:q_index] = 0
    session[:questions] = []
    session[:answers] = Hash.new
  end

  ###############################################
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
