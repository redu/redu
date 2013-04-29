module EnrollmentService
  class Facade
    include Singleton

    # Cria AssetReport entre Enrollments e Lectures.
    #
    # Caso enrollments seja omitido, todos os Enrollments do Subjects
    # serão utilizados.
    #
    # Parâmetros:
    #   - lectures: Lectures que serão associadas aos Users
    #   - (Opcional) enrollments: enrollments que serão associados às Lectures
    def create_asset_report(opts={})
      lectures = opts[:lectures]
      enrollments = opts[:enrollments]

      asset_reports = AssetReportEntityService.new(:lecture => lectures)
      asset_reports.create(enrollments)
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
      service = EnrollmentEntityService.new(:subject => subjects)
      service.create(:users => users, :role => opts[:role])
    end

    # Notifica remoção de enrollments a Vis
    # Parâmetros:
    #   enrollments: Enrollments que serão enviados para Vis
    def notify_enrollment_removal(enrollments)
      vis_adapter.notify_enrollment_removal(enrollments)
      graduated_enrollments = enrollments.select { |e| e.graduated? }
      vis_adapter.notify_remove_subject_finalized(graduated_enrollments)
    end

    # Notifica criação de enrollments a Vis
    # Parâmetros:
    #   enrollments: Enrollments que serão enviados para Vis
    def notify_enrollment_creation(enrollments)
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
      service = EnrollmentEntityService.new(:enrollment => enrollments)
      service.update_grade

      enrollments
    end

    def notify_subject_finalized(enrollments)
      vis_adapter.notify_subject_finalized(enrollments)
    end

    def notify_remove_subject_finalized(enrollments)
      vis_adapter.notify_remove_subject_finalized(enrollments)
    end

    private

    def vis_adapter
      @vis_adapter ||= VisAdapter.new
    end
  end
end
