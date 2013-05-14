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


    # /api/users/:user_id/enrollments?courses_ids[]=1
    # /api/courses/:course_id/enrollments
    def index
      @entity = find_and_authorize_entity
      course_enrollments = @entity.course_enrollments.
        includes({ :course => :environment }, :user)
      if params.has_key?(:user_id)
        course_enrollments = filter_by_course_id(course_enrollments)
      end

      decorated = course_enrollments.
        map { |e| Api::CourseEnrollmentDecorator.new(e) }

      respond_with(decorated, :represent_with => CourseEnrollmentRepresenter)
    end

    def destroy
      @enrollment = CourseEnrollment.find(params[:id])
      authorize! :destroy, @enrollment
      denrollment = Api::CourseEnrollmentDecorator.new(@enrollment)
      denrollment.unenroll

      respond_with denrollment
    end

    protected

    def filter_by_course_id(arel)
      if ids = params[:courses_ids]
        arel.where(:course_id => ids)
      else
        arel
      end
    end

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
