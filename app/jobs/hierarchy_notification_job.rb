class HierarchyNotificationJob
  attr_accessor :enrollments, :type

  def initialize(enrollments, type)
    if type == 'enrollment'
      @enrollments = enrollments.collect { |e| fill_enroll_params(e, type) }
    else
      @enrollments = enrollments
    end
    @type = type
  end

  def perform
    send_multi_request
  end

  private

  def send_multi_request
    EM.run do
      multi = EventMachine::MultiRequest.new
      url = Redu::Application.config.vis_client[:url]
      enrollments.each  do |enroll|
        multi.add EM::HttpRequest.new(url).post({
          :body => enroll.to_json,
          :head => {'Authorization' => ["core-team", "JOjLeRjcK"],
                    'Content-Type' => 'application/json' }})
      end

      multi.callback do
        EM.stop
      end
    end
  end

  # preenche os parametros para envio para visualização
  def fill_enroll_params(enrollment_id, type)
    enrollment = Enrollment.find(enrollment_id)
    course = enrollment.subject.space.course
    params = {
      :user_id => enrollment.user_id,
      :type => type,
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
