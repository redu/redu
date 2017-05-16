# -*- encoding : utf-8 -*-
class LectureableService
  # Implementa o padrão Template Method para a criação de lectureables. Filhos
  # de lectureable service precisam implementar o método #build. Caso a criação
  # do lectureable necessite de autorização ou pós-processamento é facultativa
  # a implementação dos métodos #authorize!
  def initialize(ability, lectureable_attrs={})
    @ability = ability
    @attrs = lectureable_attrs.with_indifferent_access
  end

  # Template method responsável por instanciar o lectureable. Por exemplo:
  #
  #   Lecture.new(@attrs)
  #
  def build(lecture=nil, &block)
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

  def create(lecture, &block)
    @lectureable = build(lecture, &block)
    lecture.lectureable = @lectureable

    if @lectureable.valid?
      authorize!(lecture)
      @lectureable.save
    end

    @lectureable
  end

  protected

  attr_reader :ability, :attrs
end
