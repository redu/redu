module Api
  class CourseEnrollmentDecorator
    delegate :id, :to_param, :model_name, :course, :user, :token, :email, :created_at,
      :to => :@base_enrollment

    def initialize(base)
      @base_enrollment = base
    end

    def state
      if @base_enrollment.class == UserCourseInvitation
        return 'redu_invited' if @base_enrollment.invited?
      end

      @base_enrollment.state
    end
  end
end
