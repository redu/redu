class EnrollmentObserver < ActiveRecord::Observer
    include VisClient

    def after_create(enrollment)
      params = fill_params(enrollment)
      self.send_async_info(params, Redu::Application.config.vis_client[:url])
    end

    protected

    def fill_params(enrollment)
      course = enrollment.subject.space.course
      params = {
        :user_id => enrollment.user_id,
        :type => "enrollment",
        :lecture_id => nil,
        :subject_id => enrollment.subject_id,
        :space_id => enrollment.subject.space.id,
        :course_id => course.id,
        :status_id => nil,
        :statusable_id => nil,
        :statusable_type => nil,
        :in_response_to_id => nil,
        :in_response_to_type => nil,
        :created_at => enrollment.created_at,
        :updated_at => enrollment.updated_at
      }
    end
end
