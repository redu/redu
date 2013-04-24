module EnrollmentService
  class EnrollmentEntityService
    attr_reader :subjects, :enrollments

    # Parâmetros:
    #   - :subject Subject ou coleção de Subjects para os quais os Enrollments
    #       serão criados.
    def initialize(opts={})
      @subjects = opts.delete(:subject)
      @subjects = @subjects.respond_to?(:map) ? @subjects : [@subjects]

      @enrollments = opts.delete(:enrollment)
      @enrollments = @enrollments.respond_to?(:map) ? @enrollments : [@enrollments]
    end

    # Matricula usuários no Subject.
    # Parâmetros:
    #   - Opcional: lista de pares do tipo [[User,Role]] representando os usuários
    #     a serem matriculados. Caso não seja passado os usuários do Space serão
    #     utilizados.
    def create(users_and_roles=nil)
      builder = infer_builder_from_arguments(:users_and_roles => users_and_roles)
      importer.insert(builder.to_a)
    end

    def importer
      @importer ||= EnrollmentBulkMapper.new
    end

    # Desmatricula usuários do Subject(s).
    # Parâmetros:
    #   - users: Usuários a serem desmatriculados dos subject(s).
    #
    # Atenção: Não invoca callbacks (nem remove associações :dependent).
    def destroy(users)
      users_ids = users.respond_to?(:map) ? users.map(&:id) : [users.id]
      enrollments = Enrollment.where(:subject_id => subjects)

      enrollments_ids = enrollments.values_of(:id, :user_id).map do |id, u_id|
        id if users_ids.include? u_id
      end.compact

      Enrollment.delete_all(["id IN (?)", enrollments_ids])
    end

    # Atualiza grade dos Enrollments passados na inicialização baseado nos
    # seus AssetReports.
    def update_grade
      asset_reports = AssetReport.where(:enrollment_id => enrollments)
      updated_enrollments = calculate_grade(asset_reports)
      update_enrollments(updated_enrollments)
      enrollments
    end

    private

    def calculate_grade(asset_reports)
      grader = GradeCalculator.new(asset_reports)
      grader.calculate_grade
    end

    def update_enrollments(values)
      opts = {
        :on_duplicate_key_update => [:grade, :graduated],
        :columns => [:id, :grade, :graduated]
      }
      importer.insert(values, opts)
    end

    def infer_builder_from_arguments(arguments={})
      users_and_roles = arguments[:users_and_roles] || []

      if users_and_roles.empty?
        InferredEnrollmentBuilder.new(subjects)
      else
        UsersAndRolesEnrollmentBuilder.new(subjects, users_and_roles)
      end
    end
  end
end
