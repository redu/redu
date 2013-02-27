# Serviço responsável por instanciar e criar canvas
class CanvasService
  attr_reader :access_token

  # access_token: objeto que representa o access_token
  def initialize(opts={})
    @access_token = opts[:access_token]
  end

  # Instancia canvas baseado nos atributos
  def build(params, &block)
    attrs = {
      :user_id => access_token.user.id,
      :client_application_id => access_token.client_application_id,
      :name => params[:name]
    }
    if url = params[:current_url]
      attrs.merge!({:url => url})
    end

    block_given = block_given?
    Api::Canvas.new(attrs) do |c|
      block.call(c) if block_given
    end
  end

  # Instancia e salva canvas baseado nos atributos. Retorna Api::Canvas ou lança
  # RecordNotSaved.
  def create(params, &block)
    canvas = build(params, &block)
    canvas.save
    canvas
  end
end
