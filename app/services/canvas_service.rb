# -*- encoding : utf-8 -*-
# Serviço responsável por instanciar e criar canvas
class CanvasService
  attr_reader :access_token

  # access_token: objeto que representa o access_token
  def initialize(opts={})
    @access_token = opts.delete(:access_token)
  end

  # Instancia canvas baseado nos atributos
  def build(attrs = {}, &block)
    canvas_attrs = {
      :user_id => access_token.user.id,
      :client_application_id => access_token.client_application_id,
      :name => attrs[:name],
      :url => attrs[:current_url]
    }

    block_given = block_given?
    Api::Canvas.new(canvas_attrs) do |c|
      block.call(c) if block_given
    end
  end

  def create(attrs = {}, &block)
    canvas = build(attrs, &block)
    canvas.save
    canvas
  end
end
