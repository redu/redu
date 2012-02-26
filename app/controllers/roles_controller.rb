class RolesController < BaseController
  load_and_authorize_resource :environment, :find_by => :path
  load_and_authorize_resource :user, :find_by => :login

  def show
    @user = User.find(params[:user_id])
    @environment = Environment.includes(:courses => [:spaces]).
      find_by_path(params[:environment_id])

    spaces = @environment.courses.collect{|c| c.spaces.collect{|s| s}}.flatten

    @courses = @user.user_course_associations.
      where(:course_id => @environment.courses).
      includes(:course => [{ :spaces => :user_space_associations }])
    @environment_membership = @user.user_environment_associations.
      where(:environment_id => @environment.id,:user_id => @user.id).first

    respond_to do |format|
      format.html do
        render :template => "roles/show"
      end
    end
  end

  def update
    @user = User.find(params[:user_id])
    @environment = Environment.find(params[:environment_id])

    case params[:type]
    when 'environment' then
      object = @environment
      # ao se tornar administrador, se tornará administrador para todas
      # entidades abaixo da de environment
      if !Role[params[:roles].to_i].nil? and
        params[:roles].to_i == Role[:environment_admin]

        object.courses.each do |course|
          unless @user.get_association_with(course)

            uca = UserCourseAssociation.create(:user_id => @user.id,
                                               :course_id => course.id,
                                               :role => params[:roles].to_i)
            uca.approve!

            course.spaces.each do |space|
              unless @user.get_association_with(space)
                UserSpaceAssociation.create(:user_id => @user.id,
                                            :space_id => space.id,
                                            :role => params[:roles].to_i,
                                            :status => "approved")
              end
            end
          end
        end
      end
    when 'course' then object = Course.find(params[:course_id])
    when 'space' then object = Space.find(params[:space_id])
    else
    end



    object.change_role(@user, params[:roles])

    respond_to do |format|
      format.html {redirect_to user_admin_roles_path(@user, @environment)}
      format.js do
        render(:update) { |page| page.reload }
      end
    end
  end

end
