class TeacherParticipation
  attr_accessor :lectures_created

  def initialize(uca)
    @uca = uca

    # Time de início e de fim
    @start = "2012-02-08".to_date
    @end = "2012-02-10".to_date

    # Array de id's que veio de params
    @spaces = Space.find([1,2])
  end

  # Todos os resultados tem que ser filtrados pelo período de tempo e pelas disciplinas selecionadas
  def generate!
    self.lectures_created_by_day
  end

  def lectures_created_by_day
    # Lectures criadas no total
    @total_subjects = self.subjects_space & @uca.user.subjects_id
    @total_lectures = Lecture.by_subjects(@total_subjects)
    @lectures_created = []

    (0..(@end - @start)).each do |day|
      @query = @total_lectures.where(:created_at=>(@start..(@start+1))).count
      @lectures_created << @query
      @start += 1
    end
  end

  def subjects_space
    @subjects_space = []
    @spaces.each do |space|
      @subjects_space.concat(space.subjects_id)
    end
    @subjects_space
  end
end
