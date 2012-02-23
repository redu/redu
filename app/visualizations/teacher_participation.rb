class TeacherParticipation
  attr_accessor :lectures_created, :posts, :answers

  def initialize(uca)
    @uca = uca
    @user_id = @uca.user.id

    # Time de início e de fim
    @start = "2012-02-08".to_date
    @end = "2012-02-16".to_date

    # Array de id's que veio de params
    @spaces = @uca.course.spaces.find([1,2])
  end

  # Todos os resultados tem que ser filtrados pelo período de
  # tempo e pelas disciplinas selecionadas
  def generate!
    self.lectures_created_by_space
    self.posts_by_space
    self.answers_by_space
    self.by_day
  end

  # Alinha as consultas por dia
  def by_day
    @lectures_created = []
    @posts = []
    @answers = []
    @start_aux = @start
    (0..(@end - @start)).each do
      @lectures_created << @total_lectures.by_day(@start_aux).count
      @posts << @total_posts.by_day(@start_aux).count
      @answers << @total_answers.by_day(@start_aux).count
      @start_aux += 1
    end
  end

  # Define as aulas criadas dentro daqueles spaces
  def lectures_created_by_space
    @total_subjects = self.subjects_by_space & @uca.user.subjects_id
    @total_lectures = @uca.user.lectures.by_subjects(@total_subjects)
  end

  # Define os subjects do conjunto de spaces
  def subjects_by_space
    @subjects_space = @spaces.inject([]) do |acc, space|
      acc.concat(space.subjects_id)
    end
  end

  # Todos os posts do professor naquelas disciplinas + aulas
  def posts_by_space
    @statuses_by_spaces = Status.from_hierarchy(@uca.course)
    @total_posts = @statuses_by_spaces.activity_by_user(@user_id).by_space(@spaces)
  end

  # Todas as respostas (Tanto de Help quanto de Activity) do professor naquelas disciplinas + aulas
  def answers_by_space
    @total_helps_and_activities = @statuses_by_spaces.helps_and_activities
    @answers_ids = @total_helps_and_activities.inject([]) do |acc, help|
      acc.concat(help.answers_ids(@user_id))
    end
    @total_answers = Status.by_id(@answers_ids)
  end
end
