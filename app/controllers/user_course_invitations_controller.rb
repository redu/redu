# -*- encoding : utf-8 -*-
class UserCourseInvitationsController < BaseController
  layout "clean"

  load_resource :environment, :find_by => :path
  load_resource :course, :through => :environment, :find_by => :path
  load_resource :user_course_invitation, :through => :course

  def show
    if @user_course_invitation.approved?
      flash[:notice] = "Este convite já foi utilizado."
      redirect_to application_path and return
    end

    if current_user
      @user_course_invitation.user = current_user
      @user_course_invitation.accept!
      redirect_to home_user_path(current_user) and return
    else
      @user_session = UserSession.new
    end
  end

end
