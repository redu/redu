module EnrollmentService
  class Facade
    include Singleton

    # Cria AssetReport entre todas as Lectures dos Subjects passados e os
    # Users. Caso users seja omitido, todos os Users matriculados no Subject
    # serão utilizados.
    def create_asset_report(subjects, users=nil)
      subject_ids = pluck_ids(subjects)
      lectures = Lecture.
        where(:subject_id => subject_ids).select("id, subject_id")
      asset_reports = AssetReportEntityService.new(:lecture => lectures)

      if users
        enrollments = Enrollment.
          where(:subject_id => subject_ids, :user_id => pluck_ids(users))

        asset_reports.create(enrollments)
      else
        asset_reports.create
      end
    end

    # Cria Enrollment entre os User e Subject passados.
    # Parâmetros:
    #   - subjects (obrigatório): Lista de Subject ao qual os users
    #   serão matriculados
    #   - users (opcional): Lista de User que serão matriculados. Se omitido
    #   os usuários do Space serão matriculados
    # options:
    #   - role: Papel dos usuários
    def create_enrollment(subjects, users=nil, opts={})
      options = { :role => Role[:member] }.merge(opts)

      service = EnrollmentEntityService.new(:subject => subjects)

      if users
        users_and_roles = users.map { |u| [u, options[:role].to_s] }
        service.create(users_and_roles)
      else
        service.create
      end
    end

    # Notifica remoção de enrollments a Vis
    # Parâmetros:
    #   enrollments: Enrollments que serão enviados para Vis
    def notify_enrollment_removal(enrollments)
      vis_adapter = VisAdapter.new
      vis_adapter.notify_enrollment_removal(enrollments)
      graduated_enrollments = enrollments.select { |e| e.graduated? }
      vis_adapter.notify_graduated_enrollment_removal(graduated_enrollments)
    end

    # Notifica criação de enrollments a Vis
    # Parâmetros:
    #   enrollments: Enrollments que serão enviados para Vis
    def notify_enrollment_creation(enrollments)
      vis_adapter = VisAdapter.new
      vis_adapter.notify_enrollment_creation(enrollments)
    end

    # Destrói os enrollments entre os Subjects e Users
    # Parâmetros:
    #   subjects: Subjects que os Users serão desmatriculados
    #   users: Users que serão desmatriculados
    def destroy_enrollment(subjects, users)
      enrollment_service = EnrollmentEntityService.new(:subject => subjects)
      enrollment_service.destroy(users)
    end

    # Destrói os asset reports dos Enrollments nos Subjects
    # Parâmetros:
    #   subjects: Subjects que possuem as aulas
    #   enrollments: Enrollments que terão os asset reports removidos
    def destroy_asset_report(subjects, enrollments)
      lectures = Lecture.where(:subject_id => subjects).select("id")
      asset_report_service = AssetReportEntityService.new(:lecture => \
                                                          lectures)
      asset_report_service.destroy(enrollments)
    end


    def pluck_ids(resources)
      resources.map(&:id).uniq
    end
  end
end
