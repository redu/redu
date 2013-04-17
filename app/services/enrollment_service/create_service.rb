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

    # Matricula usuários Subject.
    # Parâmetros:
    #   - Opcional: lista de pares do tipo [[User,Role]] representando os usuários
    #     a serem matriculados. Caso não seja passado os usuários do Space serão
    #     utilizados.
    def create(users_and_roles=nil)
      values = if users_and_roles
                 DecoratedEnrollmentsStrategy.new(subjects, users_and_roles).to_a
               else
                 InferredEnrollmentStrategy.new(subjects).to_a
               end

      bulk_insert(values)
    end

    protected

    def bulk_insert(values)
      columns = [:user_id, :subject_id, :role]
      options = { :validate => false, :on_duplicate_key_update => [:user_id, :role] }

      Enrollment.import(columns, values, options)
    end

    class DecoratedEnrollmentsStrategy < Struct.new(:subjects, :user_role_pairs)
      def to_a
        decorate_with_subject_ids
      end

      private

      def decorate_with_subject_ids
        subjects.reduce([]) do |memo, subject|
          user_role_pairs.each do |(user, role)|
            memo << [user.id, subject.id, role]
          end
          memo
        end
      end
    end

    class InferredEnrollmentStrategy < Struct.new(:subjects)
      # Define estratégia para definir uma matriz do tipo [user_id, subject_id, role]
      # baseado em uma coleção de Subject

      def to_a
        infer_from_subjects
      end

      private

      # Constrói matriz do tipo [user_id, subject_id, role] para os usuários
      # matriculados nos spaces dos subjects passados na inicialização
      def infer_from_subjects
        user_space_associations.reduce([]) do |memo, (user_id, space_id, role)|
          space_subjects_idx[space_id].each do |subject_id|
          memo << [user_id, subject_id, role]
        end
        memo
        end
      end

      # Contrói um índice spaces e seus subjects
      # {
      #   space_id => [s1_id, s2_id],
      #   space2_id = > [s3_id]
      # }
      def space_subjects_idx
        @space_subjects_idx ||= subject_space_pairs.reduce({}) do |memo, (subj, space)|
          memo[space] ||= []
          memo[space] << subj
          memo
        end
      end

      def user_space_associations
        space_ids = subject_space_pairs.map(&:last).uniq

        UserSpaceAssociation.
          where(:space_id => space_ids).values_of(:user_id, :space_id, :role)
      end

      # Contrói uma Lista de pares do tipo [subject_id, space_id] para os Subjects
      # passados na inicialização
      def subject_space_pairs
        @subject_space_pairs ||= subjects.map { |s| [s.id, s.space_id] }
      end

    end
  end
end
