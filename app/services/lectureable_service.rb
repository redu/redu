class LectureableService
  # Implementa o padrão Template Method para a criação de lectureables. Filhos
  # de lectureable service precisam implementar o método #build. Caso a criação
  # do lectureable necessite de autorização ou pós-processamento é facultativa
  # a implementação dos métodos #authorize! e #process!
  def initialize(ability, lectureable_attrs={})
    @ability = ability
    @attrs = lectureable_attrs.with_indifferent_access
  end

  # Template method responsável por instanciar o lectureable. Por exemplo:
  #
  #   Lecture.new(@attrs)
  #
  def build(&block)
    raise NotImplementedError.new("You need to override build method")
  end

  # Template method responsável por realizar a autorização, caso necessário,
  # para a criação de lectureable. Deve delegar a chamada para o ability,
  # disponível na instância da classe. É chamado imediatemente antes de salvar
  # o lectureable. Exemplo de implementação:
  #
  #   ability.authorize!(:manage, lecture)
  #
  def authorize!(lecture); end

  # Template method responsável por realizar pós-processamento no lectureable,
  # por exemplo, conversões de arquivos. É chamado depois que o lectureable é
  # salvo.
  def process!; end

  def create(lecture, &block)
    @lectureable = build(&block)
    lecture.lectureable = @lectureable

    if @lectureable.valid?
      authorize!(lecture)
      @lectureable.save
      process!
    end

    @lectureable
  end

  protected

  attr_reader :ability, :attrs
end
