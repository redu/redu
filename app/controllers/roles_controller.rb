class RolesController < BaseController
  layout 'environment'

  def show
    @user = User.find(params[:user_id])
    @environment = Environment.find(:first,
      :conditions => ["path LIKE ?", params[:environment_id]],
      :include => [{:courses => :spaces}])

    spaces = @environment.courses.collect{|c| c.spaces.collect{|s| s}}.flatten

    @courses = @user.user_course_associations.find(:all,
      :conditions => {:course_id => @environment.courses},
      :include => [{:course => { :spaces => :user_space_associations }}])
    @environment_membership = @user.user_environment_associations.find(:first,
      :conditions => {:environment_id => @environment.id,
                      :user_id => @user.id})
  end

  def update
    @user = User.find(params[:user_id])
    @environment = Environment.find(params[:environment_id])

    case params[:type]
    when 'environment' then object = @environment
    when 'course' then object = Course.find(params[:course_id])
    when 'space' then object = Space.find(params[:space_id])
    else
    end

    object.change_role(@user, Role.find(params[:roles]))

    respond_to do |format|
      format.html {redirect_to user_admin_roles_path(@user, @environment)}
      format.js { render :nothing => true, :status => 200 }
    end
  end
end
