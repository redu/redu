module Api
  class CourseEnrollmentsController < ApiController
    def create
      @course = Course.find(params[:course_id])
      @enrollment = @course.invite_by_email(params[:enrollment][:email])
      decorated = Api::CourseEnrollmentDecorator.new(@enrollment)

      respond_with(:api, @course, decorated,
                   :location => api_enrollment_url(@course, @enrollment),
                   :with_representer => CourseEnrollmentRepresenter)
    end

    def show
      @enrollment = CourseEnrollment.find(params[:id])
      decorated = Api::CourseEnrollmentDecorator.new(@enrollment)

      respond_with(decorated, :with_representer => CourseEnrollmentRepresenter)
    end

    def index
      @entity = find_entity
      denrollments = @entity.course_enrollments.collect do |e|
        Api::CourseEnrollmentDecorator.new(e)
      end

      respond_with(denrollments, :with_representer => CourseEnrollmentRepresenter)
    end

    def destroy
      @enrollment = CourseEnrollment.find(params[:id])
      denrollment = Api::CourseEnrollmentDecorator.new(@enrollment)
      denrollment.unenroll

      respond_with denrollment
    end

    protected

    def find_entity
      if params.has_key?(:course_id)
        Course.find(params[:course_id])
      else
        User.find(params[:user_id])
      end
    end
  end
end
