module Api
  class CourseEnrollmentsController < ApiController
    def create
      @course = Course.find(params[:course_id])
      @enrollment = @course.invite_by_email(params[:enrollment][:email])
      decorated = Api::CourseEnrollmentDecorator.new(@enrollment)

      respond_with(:api, @course, decorated,
                   :location => api_course_enrollment_url(@course, @enrollment),
                   :with_representer => CourseEnrollmentRepresenter)
    end

    def show
      @enrollment = CourseEnrollment.find(params[:id])
      decorated = Api::CourseEnrollmentDecorator.new(@enrollment)

      respond_with(decorated, :with_representer => CourseEnrollmentRepresenter)
    end

    def index
      @course = Course.find(params[:course_id])
      denrollments = @course.course_enrollments.collect do |e|
        Api::CourseEnrollmentDecorator.new(e)
      end

      respond_with(denrollments, :with_representer => CourseEnrollmentRepresenter)
    end
  end
end
