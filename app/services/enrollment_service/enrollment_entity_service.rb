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
    #   - users_and_roles (opcional): lista de pares do tipo [[User,Role]]
    #     representando os usuários a serem matriculados.
    #   - users (opcional): lista de usuários a serem matriculados.
    #   - role (opcional): papel com o qual os usuários serão matriculados.
    #
    #   Caso não seja passado nenhum argumento, os usuários do Space serão
    #   utilizados.
    #
    #   Retorna enrollments criados.
    def create(opts={})
      users_and_roles = opts[:users_and_roles]
      role = opts[:role] || Role[:member]
      users = opts[:users] || []

      users_and_roles ||= users.map { |u| [u, role.to_s] }

      builder = infer_builder_from_arguments(:users_and_roles => users_and_roles)
      values = builder.to_a
      importer.insert(values)

      users_ids = values.map(&:first)
      get_enrollments_for(User.where(:id => users_ids))
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
      enrollments = Enrollment.where(:subject_id => subjects, :user_id => users)

      Enrollment.delete_all(["id IN (?)", enrollments.values_of(:id)])
    end

    # Atualiza grade dos Enrollments passados na inicialização baseado nos
    # seus AssetReports.
    def update_grade
      updated_enrollments = calculate_grade(enrollments)
      update_enrollments(updated_enrollments)
      enrollments
    end

    def get_enrollments_for(users)
      Enrollment.where(:subject_id => subjects, :user_id => users)
    end

    private

    def calculate_grade(enrollments)
      grader = GradeCalculator.new(enrollments)
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
