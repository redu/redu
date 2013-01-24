module Api
  class CourseEnrollmentsController < ApiController
    def create
      @course = Course.find(params[:course_id])
      authorize! :manage, @course
      @enrollment = @course.invite_by_email(params[:enrollment][:email])
      decorated = Api::CourseEnrollmentDecorator.new(@enrollment)

      respond_with(:api, @course, decorated,
                   :location => api_enrollment_url(@course, @enrollment),
                   :represent_with => CourseEnrollmentRepresenter)
    end

    def show
      @enrollment = CourseEnrollment.find(params[:id])
      authorize! :read, @enrollment
      decorated = Api::CourseEnrollmentDecorator.new(@enrollment)

      respond_with(decorated, :represent_with => CourseEnrollmentRepresenter)
    end

    def index
      @entity = find_and_authorize_entity
      denrollments = @entity.course_enrollments.collect do |e|
        Api::CourseEnrollmentDecorator.new(e)
      end

      respond_with(denrollments, :represent_with => CourseEnrollmentRepresenter)
    end

    def destroy
      @enrollment = CourseEnrollment.find(params[:id])
      authorize! :destroy, @enrollment
      denrollment = Api::CourseEnrollmentDecorator.new(@enrollment)
      denrollment.unenroll

      respond_with denrollment
    end

    protected

    # /api/users/:user_id/enrollments
    # /api/courses/:course_id/enrollments
    def find_and_authorize_entity
      if params.has_key?(:course_id)
        course = Course.find(params[:course_id])
        authorize! :read, course
      else
        user = User.find(params[:user_id])
        authorize! :manage, user
      end
    end
  end
end
