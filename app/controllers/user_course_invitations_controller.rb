class UserCourseInvitationsController < BaseController
  layout "new/clean"

  load_resource :course
  load_resource :user_course_invitation, :through => :course

  def show
    @user_session = UserSession.new
  end

end
