module EnrollmentService
  class CreateEnrollment
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
      builder = if users_and_roles
        DecoratedEnrollmentsStrategy.new(subjects, users_and_roles)
      else
        InferredEnrollmentStrategy.new(subjects)
      end

      bulk_insert(builder.to_a)
    end

    protected

    def bulk_insert(values)
      columns = [:user_id, :subject_id, :role]
      options = { :validate => false, :on_duplicate_key_update => [:user_id, :role] }

      Enrollment.import(columns, values, options)
    end

  end
end
