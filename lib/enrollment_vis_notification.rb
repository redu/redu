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

  # Cria um delayed_job do tipo HierarchyNotification para enviar requisições
  # para visualização. Os params variam de acordo com o tipo, já que quando é
  # criação o enrolment pode ser descoberto na hora da execução do job, mas quando
  # for remoção tem que enviar todos os parametros completos.
  def delay_hierarchy_notification(enrollments, type)
    #unless enrollments.empty?
    #  if type == "enrollment"
    #    params = enrollments.collect { |e| e.id }
    #  else
    #    params = enrollments.collect { |e| fill_enroll_params(e, type) }
    #  end

    #  create_jobs(params, type)
    #end
  end

  # Cria diversos jobs para serem enfileirados e processados pelo dealyed_job.
  # A cada 300 cria-se um novo job para ser processado
  def create_jobs(params, type)
    params_array = []
    params_array = params.each_slice(300).to_a

    params_array.each do |p|
      job = HierarchyNotificationJob.new(p, type)
      Delayed::Job.enqueue(job, :queue => 'general')
    end
  end

  # Notifica através do em-http-request a criação do enrollment
  def notify_vis(enrollment, type)
    params = fill_enroll_params(enrollment, type)
    self.send_async_info(params, Redu::Application.config.vis_client[:url])
  end
end
