module EnrollmentVisNotification
  include VisClient

  # preenche os parametros para envio para visualização
  def fill_enroll_params(enrollment, type)
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

  # Cria um delayed_job do tipo HierarchyNotification para enviar requisições para visualização
  def delay_hierarchy_notification(enrollments, type)
    unless enrollments.empty?
     if type == "enrollment"
        params = enrollments.collect { |e| e.id }
      else
        params = enrollments.collect { |e| fill_enroll_params(e, type) }
      end
      job = HierarchyNotificationJob.new(params, type)
      Delayed::Job.enqueue(job, :queue => 'general')
    end
  end

  # Notifica através do em-http-request a criação do enrollment
  def notify_vis(enrollment, type)
    params = fill_enroll_params(enrollment, type)
    self.send_async_info(params, Redu::Application.config.vis_client[:url])
  end
end
