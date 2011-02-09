class PlansController < BaseController
  before_filter :find_course_environment

  authorize_resource

  def confirm
    @order = @plan.create_order

    respond_to do |format|
      format.html { render :layout => "environment" }
    end
  end

  def upgrade
    if request.post?
      UserNotifier.deliver_upgrade_request(current_user, @plan, params[:plan])

      respond_to do |format|
        format.html {
          render :template => "plans/upgrade_pending"
        }
      end
    end
  end

  def pay
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
