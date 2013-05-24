# -*- encoding : utf-8 -*-
module EnrollmentService
  class InferredEnrollmentBuilder < Struct.new(:subjects)
    # Define estratégia para construir uma matriz do tipo
    # [user_id, subject_id, role] baseado em uma coleção de Subject e User.

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
        where(space_id: space_ids).values_of(:user_id, :space_id, :role)
    end

    # Contrói uma Lista de pares do tipo [subject_id, space_id] para os Subjects
    # passados na inicialização
    def subject_space_pairs
      @subject_space_pairs ||= subjects.map { |s| [s.id, s.space_id] }
    end
  end
end
