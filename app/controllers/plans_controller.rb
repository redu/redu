class PlansController < BaseController

  before_filter :find_course_environment, :except => [:index, :create]

  load_and_authorize_resource :user, :find_by => :login
  load_and_authorize_resource :plan, :only => [:options], :through => :user
  load_and_authorize_resource :partner, :only => [:create, :options]

  def create
    if params[:client_id]
      @client = @partner.partner_environment_associations.find(params[:client_id])
    end

    @environment = Environment.find(params[:environment_id])
    if params[:course_id]
      @course = @environment.courses.find_by_path(params[:course_id])
    end

    @plan = @course.try(:plan) || @environment.try(:plan)
    authorize! :migrate, @plan

    @new_plan = Plan.from_preset(params[:new_plan].to_sym, params[:type])
    @plan.migrate_to @new_plan

    flash[:notice] = "O novo plano foi assinado, você pode ver a fatura abaixo."
    respond_to do |format|
      if @client
        format.html do
          redirect_to partner_client_plan_invoices_path(@partner, @client,
                                                        @new_plan)
        end
      else
        format.html do
          redirect_to plan_invoices_path(@new_plan)
        end
      end
    end
  end

  def index
    authorize! :manage, @user
    @plans = @user.plans.current.includes(:billable)

    respond_to do |format|
      format.html { render :layout => 'new_application' }
    end
  end

  def options
    authorize! :migrate, @plan

    if params[:client_id]
      @client = @partner.partner_environment_associations.find(params[:client_id])
    end

    @billable_url = if @plan.billable.is_a? Environment
                      environment_url(@plan.billable)
                    elsif @plan.billable.is_a? Course
                      environment_course_url(@plan.billable.environment,
                                              @plan.billable)
                    end

    respond_to do |format|
      if @client
        format.html { render "partner_environment_associations/plans/options" }
      else
        format.html
      end
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
