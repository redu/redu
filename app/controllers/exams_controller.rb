class ExamsController < BaseController

  before_filter :login_required, :except => [:index]
  uses_tiny_mce(:options => AppConfig.question_mce_options, :only => [:new, :edit, :create, :update])
  after_filter :create_activity, :only => [:create, :results]

  def publish_score
    ExamUser.update(params[:exam_user_id], :public => true)
    respond_to do |format|
      format.js do
        render :update do |page|
          page << "$('#pub_score').attr('value','Score publicado!')"
          #page << "$('pub_score').attr('onclick', 'return false')"
        end
      end
    end
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
    end

    # initialize session variables
    session[:exam] ||= @exam
    session[:question_index] ||= 0
    session[:prev_index] ||= 0
    session[:correct] ||= 0
    session[:answers] ||= {}

    # if user selected a question to show
    if params.has_key?(:q_index)
      # Setando o prev_index baseado no question_index anterior
      if session[:question_index] > 0
        session[:prev_index] -= 1
      else
        session[:prev_index] = 0
      end
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
    elsif !params.has_key?('first')
      redirect_to :action => "compute_results"
    end

    @step =  session[:exam].questions[session[:question_index]]
    @prev_step =  session[:exam].questions[session[:prev_index]] if session[:question_index] != session[:prev_index]
    @has_next = (session[:question_index] < (session[:exam].questions.length - 1)) ? true : false
    @has_prev = (session[:question_index] > 0)

    # Salvando respostas dadas
    if params.has_key?(:answer) && params.has_key?(:question)
      unless params[:answer].empty?
        session[:answers][params[:question].to_i] = params[:answer].to_i
      else
        session[:answers][params[:question].to_i] = nil
      end
    end
  end

  def compute_results
    @exam = session[:exam] if session[:exam]
    @answers = session[:answers] if session[:answers]
    @corrects = []
    @correct = 0

    @exam.questions.each do |question|
      #TODO setar o Question.answer no momento da criação
      if session[:answers][question.id] == question.answer.id
        @corrects << question
        @correct += 1
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
    redirect_to :action => :results, :correct => @correct, :time => params[:chrono], :exam_user_id => @exam_user.id
  end

  def results
    # TODO isso nao é muito necessario e compromete a peformace
    @alternative_letters = {}
    letters = ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j']
    @exam = session[:exam]

    @exam.questions.each_with_index do |question, k|
      question.alternatives.each_with_index do |alternative, l| #TODO dá pra otimizar aqui,isso nao eh muito necessario
        @alternative_letters[alternative.id] = letters[l]
      end
    end

    @ranking = ExamUser.ranking(@exam.id)
    @exam_user_id = params[:exam_user_id]
    @correct = params[:correct].to_i
    @time = params[:time].to_i

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
    Exam.find(session[:exam_params][:id]).destroy if session[:exam_params] and session[:exam_params][:id]
    session[:exam_params] = nil

    flash[:notice] = "Criação de exame cancelada."
    redirect_to exams_path
  end

  def new
    session[:exam_params] ||= {}
    @exam = Exam.new(session[:exam_params])
    @exam.current_step =  params[:step]
  end

  # Wizard de Exame. Nos primeiros passos as informações são guardadas na session.
  # O registo só é salvo no último passo.
  def create
    if params[:exam]
      # Evita duplicação dos campos gerados dinamicamente no passo 2
      if params[:exam].has_key?(:questions_attributes)
        session[:exam_params].delete("questions_attributes")
      end

      # Atualizando dados da sessão
      session[:exam_params].deep_merge!(params[:exam])
    end

    @exam = Exam.new(session[:exam_params])
    @exam.current_step =  params[:step]
    @exam.owner = current_user

    # Redirecionando para o passo especificado
    @exam.enable_correct_validation_group!
    if @exam.valid?
      if params[:back_button]
        @exam.previous_step
      # No último passo salvar
      elsif @exam.last_step? and @exam.save
        @exam.questions.each do |question|
          correct = question.alternatives.find(:first, :conditions => {:correct => true})
          question.answer = correct if correct
          question.save!
        end
        session[:exam_params] = nil
        flash[:notice] = "Exame criado!"
        redirect_to @exam
      else
        @exam.next_step
      end
    end

    # Criando questões e alternativas em branco
    if @exam.new_record?
      if params[:step] == 'general' || @exam.invalid? || @exam.questions.empty?
        @exam.questions.build if @exam.questions.empty?
        @exam.questions.each { |q| q.alternatives.build if q.alternatives.empty? }
      end
      render "new"
    end
  end

  def unpublished_preview
    @exam = Exam.find(session[:exam_id])

    respond_to do |format|
      format.html {render 'unpublished_preview_interactive'}
    end
  end

  def new_question
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
    @q_copy = @question.clone
    @q_copy.answer = @question.answer.clone
    @question.alternatives.each {|a|
      @q_copy.alternatives << a.clone
    }
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

    if session[:exam_id]
      @exam = Exam.find(session[:exam_id])
      @exam.questions.delete(Question.find(params[:qid]))
    end
    respond_to do |format|
      format.js do
        render :update do |page|
          page.remove "question_" + params[:qid]
          flash[:notice] = "Questão removida do exame"
          page.reload_flash
        end
      end
    end
  end

  def sort_question
    # TODO esse método não faz nada! Simplesmente alterando a posicao de cada questão no formulario,
    # altera igualmente o array de questoes que vai pra action e atualiza o modelo de exames
    render :nothing => true
  end

  def search
    @exams = Exam.find_tagged_with(params[:query])
    @exams += Exam.find(:all, :conditions => ["name LIKE ?", "%" + params[:query] + "%"])

    respond_to do |format|
      format.js do
        render :update do |page|
          page.replace_html 'all_list',
            :partial => 'exams/item', :collection => @exams, :as => :exam
          page.replace_html 'title_list', "Resultados para: \"#{params[:query]}\""
        end
      end
    end
  end

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
    @exams = current_user.exam_history.paginate :page => params[:page], :order => 'updated_at DESC', :per_page => AppConfig.items_per_page

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
    cond = Caboose::EZ::Condition.new
    cond.append ["simple_category_id = ?", params[:category]] if params[:category]

    paginating_params = {
      :conditions => cond.to_sql,
      :page => params[:page],
      :order => (params[:sort]) ? params[:sort] + ' DESC' : 'created_at DESC',
      :per_page => AppConfig.items_per_page
    }

    if params[:user_id] # exames do usuario
      @user = User.find_by_login(params[:user_id])
      @user = User.find(params[:user_id]) unless @user
      @lectures = @user.exams.paginate(paginating_params)
      render((@user == current_user) ? "user_exams_private" :  "user_exams_public")
      return
      # acho que pode ser usado para subject
      #    elsif params[:space_id] # exames da escola
      #      @space = Space.find(params[:space_id])
      #      if params[:search] # search exams da escola
      #        @exams = @space.exams.name_like_all(params[:search].to_s.split).ascend_by_name.paginate(paginating_params)
      #      else
      #        @exams = @space.exams.paginate(paginating_params)
      #      end
    else # index (Exam)
      if params[:search] # search
        @exams = Exam.name_like_all(params[:search].to_s.split).ascend_by_name.paginate(paginating_params)
      else
        @exams = Exam.published.paginate(paginating_params)
      end
    end

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @exams }
      format.js
    end

  end

  # GET /exams/1
  # GET /exams/1.xml
  def show
    @exam = Exam.find(params[:id])

    @related_exams = []
    @status = Status.new

    if @exam.removed
      redirect_to removed_page_path and return
    end

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
