class PlansController < BaseController
  layout "application"

  before_filter :find_course_environment, :except => :index

  authorize_resource
  load_and_authorize_resource :user, :only => :index
  load_and_authorize_resource :plan, :only => :index, :through => :user

  def upgrade
    if request.post?
      UserNotifier.upgrade_request(current_user, @plan, params[:plan]).deliver

      respond_to do |format|
        format.html {
          render :template => "plans/upgrade_pending"
        }
      end
    end
  end

  def index
    @plans = @user.plans.find(:all, :include => :billable)

    respond_to do |format|
      format.html
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
