class QuestionsController < BaseController


  
  
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
    #@question.uploaded_data = params[:question]
    
    if params[:image] 
      puts 'tem imagem!!!'
      @image       = Image.new(params[:image])
      @question.image = @image
    end
    
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
