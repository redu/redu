class SubjectsController < BaseController
  layout 'environment'

  before_filter :login_required
  before_filter :find_subject, :except => [:new, :create, :index, :cancel]
  before_filter :find_space_course_environment, :except => [:cancel]

  uses_tiny_mce(:options => AppConfig.simple_mce_options, :only => [:new, :edit, :create, :update])

  def index
    @space = Space.find(params[:space_id])
    cond = Caboose::EZ::Condition.new

    paginating_params = {
      :conditions => cond.to_sql,
      :page => params[:page],
      :order => (params[:sort]) ? params[:sort] + ' DESC' : 'created_at DESC',
      :per_page => AppConfig.items_per_page
    }

    if params[:search] # search cursos da escola
      @subjects = @space.subjects.name_like_all(params[:search].to_s.split).ascend_by_name.paginate(paginating_params)
    else
      @subjects = @space.subjects.paginate(paginating_params)
    end

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @subjects }

      format.js  do
        if params[:space_content]
          render :update do |page|
            page.replace_html  'content_list', :partial => 'subject_list'
            page << "$('#spinner').hide()"
          end
        else
          render :index
        end
      end
    end
  end


  def show
    @space = @subject.space

    #student_profile = current_user.student_profiles.find_by_subject_id(@subject.id)
    #@percentage = student_profile.nil? ? 0 : student_profile.coursed_percentage(@subject)
    @status = Status.new
    @statuses = @subject.recent_activity(0,10)

    respond_to do |format|
      format.html
    end

  end

  def lazy
    @space = @subject.space

    respond_to do |format|
      format.html
    end
  end

  def new
    session[:subject_params] ||= {}
    @subject = Subject.new
  end

  def create

    if params[:subject]
      # Evita duplicação dos campos gerados dinamicamente no passo 2
      if params[:subject].has_key?(:lazy_assets_attributes)
        session[:subject_params].delete("lazy_assets_attributes")
      end
      # Atualizando dados da sessão
      session[:subject_params].deep_merge!(params[:subject])
    end

    @subject = current_user.subjects.new(session[:subject_params])
    # Evita que ao dar refresh vá para o proximo passo.
    @subject.current_step = params[:step]

    # Redirecionando para o passo especificado
    @subject.enable_correct_validation_group!

    if params[:back_button]
      @subject.previous_step
    elsif  @subject.valid?
      if @subject.last_step?
        # No último passo, verifica se está tudo ok para salvar.
        if @subject.all_valid?
          @subject.save
          @subject.clone_existent_assets!
        end
      else
        @subject.next_step
        @subject.lazy_assets.build
      end
      session[:subject_step]= @subject.current_step
    end

    if @subject.new_record?

      if (params[:step] == 'lecture' || @subject.invalid? ||
        @subject.lazy_assets.empty?) && @subject.lazy_assets.empty?
          @subject.lazy_assets.build
      end
      render "new"
    else
      session[:subject_step] = session[:subject_params] = nil
      redirect_to subject_path(@subject)
    end
  end

  def cancel
    session[:subject_step] = session[:subject_params]= session[:subject_id]= nil
    redirect_to space_path(:id => params[:space_id])
  end

  def edit
    @subject = Subject.find(params[:id])
    session[:subject_params] ||= {}
    @existent_spaces = @course.spaces.collect { |s| [s.name, s.id] }
  end

  def update

    @subject = Subject.find(params[:id])
    if params[:subject]
      # Evita duplicação dos campos gerados dinamicamente no passo 2
      if params[:subject].has_key?(:lazy_assets_attributes)
        session[:subject_params].delete("lazy_assets_attributes")
      end
      # Atualizando dados da sessão
      session[:subject_params].deep_merge!(params[:subject])
    end

    # Evita que ao dar refresh vá para o proximo passo.
    @subject.current_step = params[:step]

    # Redirecionando para o passo especificado
    @subject.enable_correct_validation_group!

    if params[:back_button]
      @subject.previous_step
      render "edit"
      # TODO Remover quando atualizar a versão do Rails, workaround para bug.
      # O _destroy não causava a remoção do ActiveRecord.
    elsif @subject.lazy_assets(true) and @subject.update_attributes(session[:subject_params])
      if @subject.last_step?
        @subject.clone_existent_assets!
        session[:subject_step] = session[:subject_params] = nil
        redirect_to subject_path(@subject)
      else
        @subject.next_step
        session[:subject_step]= @subject.current_step
        render "edit"
      end
    else
    render "edit"
    end
  end

  def unpublish
    #TODO depende de enrollments
  end

  def publish
    unless @subject.assets.empty?
      @subject.published = true
      @subject.save

      respond_to do |format|
        format.html do
          @space = @subject.space
          flash[:notice] = "Módulo publicado"
          redirect_to :action => "show"
        end
      end
    else
      flash[:notice] = "Para se publicado o módulo deve possuir pelo menos " + \
        "uma aula finalizada"
      respond_to do |format|
        format.html { render "lazy" }
      end
    end
  end

  def destroy
    @subject.destroy
    redirect_to :action =>"admin_subjects"
  end

  def enroll
    begin
      redirect_to(subjects_path) and return unless @subject.is_public
      Enrollment.create_enrollment(@subject.id, current_user)
      StudentProfile.create_profile(@subject.id, current_user)
      flash[:notice] = "Você se inscreveu neste curso!"
      redirect_to @subject
    rescue Exception => e #exceçao criada no model de Enrollment
      flash[:notice] =  e.message
      redirect_to subjects_path
    end

  end

  # Altera a ordem dos recursos já finalizados.
  def change_assets_order
   assets_order = params[:assets_order].split(",")
   ids_ordered = []
   assets_order.each do |asset|
     ids_ordered << asset.split("-")[0].to_i
   end

   ids_ordered.each_with_index do |id, i|
     asset = Asset.find(id)
     asset.position = i + 1 # Para não ficar índice zero.
     asset.save
   end

   flash[:notice] = "A ordem dos recursos foi atualizada."
   redirect_to admin_assets_order_space_subject_path(@subject.space, @subject)
  end

  # Página com as informações do Subject.
  def infos
   @subject = Subject.find(params[:id])
  end

  def statuses
    @status = Status.new
    @statuses = @subject.recent_activity(0,10)
  end

  protected
  def find_subject
   @subject = Subject.find(params[:id])
  end

  def find_space_course_environment
    if @subject
      @space = @subject.space
    elsif params[:space_id]
      @space = Space.find(params[:space_id])
    end
    if @space
      @course = @space.course
      @environment = @course.environment
    end
  end
end
