module EnrollmentVisNotification

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
      params = enrollments.collect { |e| fill_enroll_params(e, type) }
      job = HierarchyNotificationJob.new(params)
      Delayed::Job.enqueue(job, :queue => 'general')
    end
  end
end
