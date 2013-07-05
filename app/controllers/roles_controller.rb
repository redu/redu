# -*- encoding : utf-8 -*-
class RolesController < BaseController
  load_resource :environment, :find_by => :path
  load_resource :user, :through => :environment, :find_by => :login

  def index
    authorize! :manage, @environment

    @courses_memberships = @user.user_course_associations.
      where(:course_id => @environment.courses.select('id')).includes(:course)
    @environment_membership = @user.user_environment_associations.
      where(:environment_id => @environment.id).includes(:user).first

    respond_to do |format|
      format.html do
        render :template => "roles/show"
      end
    end
  end

  def update
    authorize! :manage, @environment

    if course_id = params[:course_id]
      @course = @environment.courses.find_by_path(course_id)
      authorize! :manage, @course
    end

    role = Role.find(params[:role])

    if @course && @environment # mudando papel num curso especifico
      @course.change_role(@user, role) unless @user.environment_admin?(@course)
    else
      if role == Role[:environment_admin]
        @environment.courses.each  {|c| c.join!(@user) }
      end
      @environment.change_role @user, role
    end

    respond_to do |format|
      format.html { redirect_to environment_user_roles_path(@environment) }
      format.js do
        render :js => "window.location = '#{environment_user_roles_path(@environment)}'"
      end
    end
  end

end
