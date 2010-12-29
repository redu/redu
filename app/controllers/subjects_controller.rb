class SubjectsController < BaseController
  layout 'environment'

  before_filter :login_required
  before_filter :find_space_course_environment

  load_and_authorize_resource :environment
  load_and_authorize_resource :course, :through => :environment
  load_and_authorize_resource :space, :through => :course
  load_and_authorize_resource :subject, :through => :space, :except => [:new, :create]

  rescue_from CanCan::AccessDenied do |exception|
    flash[:notice] = "Você não tem acesso a essa página"
    redirect_to preview_environment_course_path(@environment, @course)
  end

  def index
    cond = {}
    if can?(:manage, @course)
      cond[:published] = params.fetch(:published, true)
    else
      cond[:published] = true
    end

    paginating_params = {
      :conditions => cond,
      :page => params[:page],
      :order => (params[:sort]) ? params[:sort] + ' DESC' : 'created_at DESC',
      :per_page => AppConfig.items_per_page
    }

    @subjects = @space.subjects.paginate(paginating_params)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @subjects }

      format.js  do
        render :update do |page|
          page.replace_html 'tabs-2-content', :partial => 'subject_list'
          page << "$('#spinner').hide()"
        end
      end
    end
  end


  def show
    respond_to do |format|
      format.html
    end
  end

  # Finalização da criação (LazyAssets com existent == false)
  def lazy
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
    @subject.space = @space
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
      if @subject.ready_to_be_published?
        redirect_to space_subject_path(@space, @subject)
      else
        redirect_to lazy_space_subject_path(@space, @subject)
      end
    end
  end

  # Cancela wizard (limpando sessão)
  def cancel
    session[:subject_step] = session[:subject_params]= session[:subject_id]= nil
    redirect_to space_path(@space)
  end

  def edit
    session[:subject_params] ||= {}
  end

  #TODO edita os LazyAssets
  def edit_resources
    session[:subject_params] ||= {}
  end

  def update
    # Evita que ao dar refresh vá para o proximo passo.
    @subject.current_step = "subject"

    # Redirecionando para o passo especificado
    @subject.enable_correct_validation_group!

    if @subject.update_attributes(params[:subject])
      flash[:notice] = "Informações atualizadas"
      redirect_to edit_space_subject_path(@space, @subject)
    else
      render "edit"
    end
  end

  #TODO Edição dos resources
  def update_resources
    # Evita que ao dar refresh vá para o proximo passo.
    @subject.current_step = "subject"

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
        redirect_to space_subject_path(@space, @subject)
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
    ActiveRecord::Base.transaction do
      @subject.published = false
      @subject.enrollments.clear
      @subject.student_profiles.clear
      @subject.save!
    end

    flash[:notice] = "Módulo despublicado, todos os alunos foram perdidos"
    respond_to do |format|
      format.html { render "show" }
    end
  end

  def publish
    unless @subject.assets.empty?
      @subject.published = true
      @subject.save

      # Matricula o dono do subject no mesmo.
      create_enroll_associations

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
    redirect_to space_path(@space)
  end

  # Matricula usuário no Subject utilizando o mesmo papel que ele possui no Space
  def enroll
    unless @subject.published?
      flash[:notice] = "Este módulo precisa ser publicado antes de receber "  + \
        "inscrições."
      redirect_to space_subject_path(@space, @subject) and return
    end

   create_enroll_associations

    flash[:notice] = "Você se inscreveu neste curso!"
    redirect_to space_subject_path(@space, @subject)
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
   redirect_to admin_assets_order_space_subject_path(@space, @subject)
  end

  # Página com as informações do Subject.
  def infos
  end

  # Mural do Subject
  def statuses
    @status = Status.new
    @statuses = @subject.recent_activity(0,10)
  end

  def next
    profile = current_user.student_profiles.find(:first,
                                       :conditions => {:subject_id => @subject})

    # Tornando o asset done (para que a contagem seja atualizada)
    current_asset = Asset.find(:first,
      :conditions => {:assetable_type => params[:assetable_type],
                      :assetable_id => params[:assetable_id]})


    report = current_asset.asset_reports.find(:first,
                :conditions => {:student_profile_id => profile})
    if params.has_key?(:done)
      report.done = true
      report.save!
      profile.update_grade!

      flash[:notice] = "Parabéns, você terminou o módulo #{@subject.title}" if profile.graduaded
    end
    next_asset = current_asset.next

    if next_asset
      if next_asset.assetable.class.to_s.eql?('Exam')
        redirect_to space_subject_exam_path(@space, @subject,
                                            next_asset.assetable)
      else
        redirect_to space_subject_lecture_path(@space, @subject,
                                               next_asset.assetable)
      end
    else
      #TODO página com relatório de desempenho
      redirect_to space_subject_path(@space, @subject)
    end
  end

  protected

  def find_space_course_environment
    @space = Space.find(params[:space_id])
    @course = @space.course
    @environment = @course.environment
  end

  def create_enroll_associations
    unless current_user.enrolled?(@subject)
      #FIXME isso é realmente necessário?
      ActiveRecord::Base.transaction do
        space_association = @space.user_space_associations.find(:first,
                                                                :conditions => {:user_id => current_user})

        profile = StudentProfile.create({:user => current_user,
                                        :subject => @subject })
        enrollment = Enrollment.create({:user => current_user,
                                       :subject => @subject,
                                       :student_profile => profile,
                                       :role => space_association.role})

        @subject.assets.each do |asset|
          AssetReport.create({:asset => asset,
                             :student_profile => profile,
                             :subject => @subject})
        end
      end
    end
  end
end
