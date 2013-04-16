require 'ruby-prof'

class EnrollmentService
  attr_reader :subjects

  # Parâmetros:
  #   - :subject Subject ou coleção de Subjects para os quais os Enrollments
  #       serão criados.
  def initialize(opts={})
    @subjects = opts.delete(:subject)
    @subjects = @subjects.respond_to?(:map) ? @subjects : [@subjects]
  end

  # Matricula todos os usuários do Space no Subject passado na inicialização
  # mantendo seus papéis.
  def create
    import(values)
  end

  protected

  # Constrói matriz do tipo [user_id, subject_id, role] para os usuários
  # matriculados nos spaces dos subjects passados na inicialização
  def values
    user_space_associations.reduce([]) do |memo, (user_id, space_id, role)|
      space_subjects_idx[space_id].each do |subject_id|
        memo << [user_id, subject_id, role]
      end
      memo
    end
  end

  # Contrói uma Lista de pares do tipo [subject_id, space_id] para os Subjects
  # passados na inicialização
  def subject_space_pairs
    @subject_space_pairs ||= subjects.map { |s| [s.id, s.space_id] }
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

  def import(values)
    columns = [:user_id, :subject_id, :role]
    options = { :validate => false, :on_duplicate_key_update => [:user_id, :role] }

    Enrollment.import(columns, values, options)
  end
end
