# Serviço responsável por instanciar e criar canvas
class LectureableCanvasService < LectureableService
  # Parâmetros:
  #   - ability: Instância do Ability
  # Options:
  #   - access_token: objeto que representa o access_token
  def initialize(ability, opts={})
    @canvas_service = CanvasService.new(opts)
    super
  end

  # Instancia canvas baseado nos atributos
  def build(&block)
    @canvas_service.build(attrs, &block)
  end

  def access_token
    @canvas_service.access_token
  end
end

