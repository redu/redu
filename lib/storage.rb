# -*- encoding : utf-8 -*-
class Storage
  # Responsável por contabilizar o espaço utilizado em todos os níveis da
  # hierarquia.

  def initialize(environment)
    @env = environment
  end

  # Quantidade em bytes de MyFile, Document e Seminar
  def total
    myfiles_size + documents_size + seminars_size
  end

  # Quantidade de bytes de todos os MyFile
  def myfiles_size
    myfiles.collect(&:attachment_file_size).reduce(:+) || 0
  end

  # Quantidade de bytes de todos os Document
  def documents_size
    size = lectureables.select { |l| l.is_a? Document }.
      collect(&:attachment_file_size).compact.reduce(:+)
    size || 0
  end

  # Quantidade de bytes de todos os Seminar
  def seminars_size
    size = lectureables.select { |l| l.is_a? Seminar }.collect(&:media_file_size).
      compact.reduce(:+)

    size || 0
  end

  # Quantidade em bytes de todos os avatars de todos os User matriculados
  def avatars_size
    styles = [:original] + (User.new.avatar.styles.keys || [])
    @avatars_size ||= users.collect do |u|
      styles.collect do |style|
        begin
          u.avatar.s3_object(style).content_length
        rescue NoMethodError
          nil
        end
      end.compact
    end.compact.flatten
    @avatars_size.reduce(:+)
  end

  protected

  def myfiles
    @myfiles ||= spaces.collect(&:folders).flatten.collect(&:myfiles).flatten
  end

  def courses
    @courses ||= @env.courses
  end

  def spaces
    @spaces ||= courses.collect(&:spaces).flatten
  end

  def lectureables(filter=nil)
    @lectureables ||= subjects.collect(&:lectures).flatten.
      collect(&:lectureable).flatten
  end

  def subjects
    @subjects ||= spaces.collect(&:subjects).flatten
  end

  def users
    @users ||= @env.users
  end
end
