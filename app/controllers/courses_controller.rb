class CoursesController < BaseController
  layout "environment"

  uses_tiny_mce(:options => AppConfig.simple_mce_options, :only => [:new, :edit, :create, :update])

  def show
    @environment = Environment.find(params[:environment_id])
    @course = Course.find(params[:id])

    respond_to do |format|
      format.html
    end
  end

  def edit
    @environment = Environment.find(params[:environment_id])
    @course = Course.find(params[:id])
  end

  def destroy
    @course = Course.find(params[:id])
    @course.destroy
    @environment = Environment.find(params[:environment_id])

    respond_to do |format|
      flash[:notice] = "Curso removido."
      format.html { redirect_to(environment_path(@environment)) }
      format.xml  { head :ok }
    end
  end

  def update
    @course = Course.find(params[:id])
    @environment = Environment.find(params[:environment_id])

    respond_to do |format|
      if @course.update_attributes(params[:course])
        flash[:notice] = 'O curso foi editado.'
        format.html { redirect_to(environment_course_path(@environment, @course)) }
        format.xml { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @course.errors, :status => :unprocessable_entity }
      end
    end
  end

  def new
    @course_being_created = Course.new
    @environment = Environment.find(params[:environment_id])
  end

  def create
    #TODO verificar permissoes
    @environment = Environment.find(params[:environment_id])
    @course = Course.new(params[:course])

    respond_to do |format|
      if @course.save
        @environment.courses << @course
        format.html { redirect_to environment_course_path(@environment, @course) }
      else
        format.html { render :action => :new }
      end
    end

  end

  def admin_spaces
    @course = Course.find(params[:id])
    @environment = @course.environment
    @spaces = Space.paginate(:conditions => ["course_id = ?", @course.id],
                                   :include => :owner,
                                   :page => params[:page],
                                   :order => 'updated_at ASC',
                                   :per_page => 20)

    respond_to do |format|
      format.html
    end
  end

  def join
    @environment = Environment.find(params[:environment_id])
    @course = Course.find(params[:id])

    association = UserCourseAssociation.new
    association.user = current_user
    association.course = @course
    association.role = Role[:member]
    association.save
  end

  def unjoin
  end

end
