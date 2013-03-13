module EnrollmentVisNotification
  include VisClient

  # Notifica através do em-http-request a criação do enrollment
  def send_to_vis(enrollment, type)
    params = enrollment
    params = fill_enroll_params(enrollment, type) if to_fill? type
    self.send_async_info(params,
                        Redu::Application.config.vis_client[:url])
  end

  def to_fill?(type)
    type == "enrollment"
  end

  # Cria um job do tipo HierarchyNotification para enviar
  # requisições para visualização. Os params variam de acordo com
  # o tipo, já que quando é criação o enrolment pode ser descoberto na
  # hora da execução do job, mas quando
  # for remoção tem que enviar todos os parametros completos.
  def delay_hierarchy_notification(type, *enrollments)
    enrollments.flatten! if !enrollments.empty? &&
      ((enrollments.first.is_a? ActiveRecord::Relation) ||
       (enrollments.first.is_a? Array))
    unless enrollments.empty?
      if type == "enrollment"
        params = enrollments.collect { |e| e.id }
      else
        params = enrollments.collect { |e| fill_enroll_params(e, type) }
      end

      create_jobs(params, type)
    end
  end

  # Cria diversos jobs, tanto quantos forem os enrollments criados, para
  # serem enfileirados e processados pelo dealyed_job.
  def create_jobs(params, type)
    params.each do |p|
      job = HierarchyNotificationJob.new(p, type)
      Delayed::Job.enqueue(job, :queue => 'general')
    end
  end

  # Preenche os parametros para envio para visualização
  def fill_enroll_params(enrollment, type)
    enrollment = find_enrollment(enrollment)
    if enrollment
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

  def find_enrollment(enrollment)
    if enrollment.is_a? Enrollment
      enrollment
    else
      enrollment = Enrollment.find_by_id(enrollment)
    end
  end
end
