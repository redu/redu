module EnrollmentService
  class Facade
    include Singleton

    # Cria AssetReport entre Users e Lectures. Caso sejam passadas as
    # Lectures, os usuários serão ligados a elas. Caso sejam passados
    # os Subjects, os usuários serão ligados às Lectures destes Subjects.
    #
    # Caso users seja omitido, todos os Users matriculados no Subjects
    # (passados como argumento ou Subjects das Lectures passadas como
    # argumento) serão utilizados.
    #
    # Parâmetros:
    #   - subjects: Subjects que contém as lectures
    #     ou
    #   - lectures: Lectures que serão associadas aos Users
    #   - (Opcional) users: Users que serão associados às Lectures
    def create_asset_report(opts={})
      subjects = opts[:subjects]
      lectures = opts[:lectures]
      users = opts[:users]

      lectures ||= Lecture.where(:subject_id => subjects).
        select("id, subject_id")
      asset_reports = AssetReportEntityService.new(:lecture => lectures)

      subjects_ids = subjects || lectures.map(&:subject_id)

      if users
        enrollments = Enrollment.
          where(:subject_id => subjects_ids, :user_id => users)

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

    # Atualiza os campos #grade e #graduated dos Enrollments passados.
    def update_grade(enrollments)
      service = EnrollmentEntityService.new(:enrollments => enrollments)
      service.update_grade
    end
  end
end
