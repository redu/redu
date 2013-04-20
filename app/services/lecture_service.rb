class LectureService
  # Implementa serviço de criação de Lecture e garante que as políticas definidas
  # em ability sejam checadas.
  def initialize(ability, lecture_attrs={})
    @ability = ability
    @attrs = lecture_attrs.with_indifferent_access
  end

  # Cria Lecture e lectureable com os atributos passados na inicialização.
  # Também implementa estratégia de conversão e autorização dos lectures e
  # lectureables. Exemplo
  #
  #   service = Lecture.new(current_ability, params[:lecture])
  #   service.create do |l|
  #     l.subject = subject
  #     l.owner = current_user
  #   end
  #
  def create(&block)
    lecture = build do |l|
      block.call(l) if block
      l.lectureable = lectureable_service.create(l)
    end

    lecture.save
    create_asset_report(lecture, lecture.owner)

    lecture
  end

  def build(&block)
    Lecture.new do |l|
      l.name = @attrs[:name]
      l.position = @attrs[:position]
      block.call(l) if block
    end
  end

  protected

  def create_asset_report(lecture, user)
    return if lecture.new_record?

    if enrollment = user.get_association_with(lecture)
      lecture.create_asset_report(:enrollments => [enrollment])
    end
  end

  # Factory method responsável por criar o LectureableService baseado
  # em @attrs[:type]
  def lectureable_service
    @lectureable ||= case @attrs[:type]
    when 'Canvas'
      LectureableCanvasService.new(@ability, @attrs)
    when 'Media'
      SeminarService.new(@ability, @attrs)
    when 'Page'
      PageService.new(@ability, @attrs)
    else 'Document' # default
      DocumentService.new(@ability, @attrs)
    end
  end
end
