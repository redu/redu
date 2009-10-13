class QuestionsController < BaseController
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
=end 
  def checkanswer # http://www.ruby-forum.com/topic/195776
    @quiz = Quiz.find(params[:quiz_id]) # get the quiz from the response 
    form
    answers = @quiz.answers
    responses = params[:responses]  # get the responses from the 
    response form
    @correct_answer_count = answers.zip(responses).map(0) {|sum, a, r| a == r ? sum + 1 : sum}
    @percentage = (@correct_answer_count / @quiz.questions.size) * 100

  end

  
  
  # GET /questions
  # GET /questions.xml
  def index
    @questions = Question.all

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
    
    @alternatives = params[:alternative][:statement]
    
    @alternatives.each do |alternative|
     # QuestionExamAssociation
      @question.alternatives << Alternative.new(:statement => alternative)
    end
    
    respond_to do |format|
      if @question.save! && params[:answer]
       # TODO fazer verificação disto (é sempre na ordem correta?)
       @answer = @question.alternatives[params[:answer].to_i]
       @question.update_attribute(:answer, @answer)
       
        flash[:notice] = 'Question was successfully created.'
        format.html { redirect_to(@question) }
        format.xml  { render :xml => @question, :status => :created, :location => @question }
      else
        flash[:notice] = 'Um erro aconteceu'
        render :nothing
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
        format.html { redirect_to(@question) }
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
