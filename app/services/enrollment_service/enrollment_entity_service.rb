module EnrollmentService
  class EnrollmentEntityService
    attr_reader :subjects

    # Parâmetros:
    #   - :subject Subject ou coleção de Subjects para os quais os Enrollments
    #       serão criados.
    def initialize(opts={})
      @subjects = opts.delete(:subject)
      @subjects = @subjects.respond_to?(:map) ? @subjects : [@subjects]
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
      users_ids = users.map(&:id)
      enrollments = Enrollment.where(:subject_id => subjects.map(&:id))

      enrollments_ids = enrollments.flatten.map do |e|
        e.id if users_ids.include? e.user_id
      end.compact

      Enrollment.delete_all(["id IN (?)", enrollments_ids])
    end

    protected

    def infer_builder_from_arguments(arguments={})
      if users_and_roles = arguments[:users_and_roles]
        UsersAndRolesEnrollmentBuilder.new(subjects, users_and_roles)
      else
        InferredEnrollmentBuilder.new(subjects)
      end
    end
  end
end
