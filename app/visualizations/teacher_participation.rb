# -*- encoding : utf-8 -*-
class TeacherParticipation
  attr_reader :lectures_created, :posts, :answers, :days
  attr_accessor :end, :start, :spaces

  def initialize(uca)
    @uca = uca
    @user_id = @uca.user.id

    @lectures_created = []
    @posts = []
    @answers = []
    @days = []

    # O default é fazer a consulta em todos os spaces de course
    # nos últimos 10 dias
    @end = Date.today
    @start = @end - 9
    @spaces = @uca.course.spaces
  end

  # Todos os resultados tem que ser filtrados pelo período de
  # tempo e pelas disciplinas selecionadas
  def generate!
    self.lectures_created_by_space
    self.posts_by_space
    self.answers_by_space
    self.by_day!
  end

  # Alinha todas as consultas por dia
  def by_day!
    (0..(self.end - self.start)).each do
      self.lectures_created << @total_lectures.by_day(self.start).count
      self.posts << @total_posts.by_day(self.start).count
      self.answers << @total_answers.by_day(self.start).count
      self.days << self.start.strftime("%-d/%m")
      self.start += 1
    end
  end

  # Define as aulas criadas dentro daqueles spaces
  def lectures_created_by_space
    total_subjects = self.subjects_by_space & @uca.user.subjects_id
    @total_lectures = @uca.user.lectures.by_subjects(total_subjects)
  end

  # Define os subjects do conjunto de spaces
  def subjects_by_space
    subjects_space = self.spaces.inject([]) do |acc, space|
      acc.concat(space.subjects_id)
    end
  end

  # Todos os posts do professor naquelas disciplinas + aulas
  def posts_by_space
    # Statuses do curso
    @statuses = Status.from_hierarchy(@uca.course)
    posts = @statuses.activity_by_user(@user_id)

    # Aulas do curso
    @lectures = Lecture.by_subjects(self.subjects_by_space)
    statusable_ids = posts.by_statusable("Lecture", @lectures)
    statusable_ids += posts.by_statusable("Space", @spaces)

    @total_posts = posts.by_id(statusable_ids)
  end

  # Todas as respostas (Tanto de Help quanto de Activity)
  # do professor naquelas disciplinas + aulas
  def answers_by_space
    helps_activities = @statuses.helps_and_activities

    # Qualquer post da disciplina + aulas
    statusable_ids = helps_activities.by_statusable("Lecture", @lectures)
    statusable_ids += helps_activities.by_statusable("Space", @spaces)
    total_helps_and_activities = helps_activities.by_id(statusable_ids)

    # Respostas à qualque post da disciplina + aulas
    answers_ids = total_helps_and_activities.inject([]) do |acc, help|
      acc.concat(help.answers_ids(@user_id))
    end

    @total_answers = Status.by_id(answers_ids)
  end
end
