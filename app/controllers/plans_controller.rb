class PlansController < BaseController

  before_filter :find_course_environment, :except => [:index, :create]

  authorize_resource
  load_and_authorize_resource :user, :only => :index, :find_by => :login
  load_and_authorize_resource :plan, :only => :index, :through => :user

  def create
    @environment = Environment.find(params[:environment_id])
    if params[:course_id]
      @course = @environment.courses.find_by_path(params[:course_id])
    end

    @plan = @course.try(:plan) || @environment.try(:plan)
    @new_plan = Plan.from_preset(params[:new_plan].to_sym)
    @plan.migrate_to @new_plan

    flash[:notice] = "O novo plano foi assinado, você pode ver a fatura abaixo."
    redirect_to plan_invoices_path(@new_plan)
  end

  def index
    @plans = @user.plans.current.includes(:billable)

    respond_to do |format|
      format.html
    end
  end

  def options
    @billable_url = if @plan.billable.is_a? Environment
                      environment_url(@plan.billable)
                    elsif @plan.billable.is_a? Course
                      environment_course_url(@plan.billable.environment,
                                              @plan.billable)
                    end
  end

  protected

  def find_course_environment
    @plan = Plan.find(params[:id])

    if @plan.billable_type == 'Course'
      @course = @plan.billable
      @environment = @course.environment
    end
  end
end
