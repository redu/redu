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
    #
    #   Retorna os enrollments criados.
    def create_enrollment(subjects, users=nil, opts={})
      service = EnrollmentEntityService.new(:subject => subjects)
      enrollments = service.create(:users => users, :role => opts[:role])

      untied_adapter.notify_after_create(enrollments)
      vis_adapter.notify_enrollment_creation(enrollments)

      enrollments
    end

    # Destrói os enrollments entre os Subjects e Users
    # Parâmetros:
    #   subjects: Subjects que os Users serão desmatriculados
    #   users: Users que serão desmatriculados
    def destroy_enrollment(subjects, users)
      enrollment_service = EnrollmentEntityService.new(:subject => subjects)

      enrollments = enrollment_service.get_enrollments_for(users)
      untied_adapter.notify_after_destroy(enrollments)
      notify_enrollment_removal(enrollments)

      enrollment_service.destroy(users)
    end

    # Destrói os asset reports dos Enrollments nas Lectures
    # Parâmetros:
    #   lectures: Lectures que possuem os asset reports
    #   enrollments: Enrollments que terão os asset reports removidos
    def destroy_asset_report(lectures, enrollments)
      asset_report_service = AssetReportEntityService.new(:lecture => lectures)
      asset_report_service.destroy(enrollments)
    end

    # Atualiza os campos #grade e #graduated dos Enrollments passados.
    def update_grade(enrollments)
      service = EnrollmentEntityService.new(:enrollment => enrollments)
      state_manager = EnrollmentStateManager.new(enrollments)

      state_manager.notify_vis_if_enrollment_change do
        service.update_grade
      end

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

    def untied_adapter
      @untied_adapter ||= UntiedAdapter.new
    end

    def notify_enrollment_removal(enrollments)
      graduated_enrollments = enrollments.where(:graduated => true)
      vis_adapter.notify_remove_subject_finalized(graduated_enrollments)

      vis_adapter.notify_enrollment_removal(enrollments)
    end
  end
end
