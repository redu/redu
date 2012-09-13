module Api
  class CourseEnrollmentDecorator
    delegate :id, :to_param, :model_name, :course, :user, :token, :email,
      :created_at, :to_hash, :updated_at,
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

    # Lógica de desmatricular para UCI e UCA
    def unenroll
      if @base_enrollment.kind_of? UserCourseAssociation
        @base_enrollment.course.unjoin(@base_enrollment.user)
      else
        @base_enrollment.destroy
      end
    end
  end
end
