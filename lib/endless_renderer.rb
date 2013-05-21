# -*- encoding : utf-8 -*-
# Renderer do WillPaginate responsável por renderizar
# a paginação no formato de Endless.
class EndlessRenderer < WillPaginate::ViewHelpers::LinkRenderer

  # A paginação só mostrará a próxima página
  def pagination
    [:next_page]
  end

  # Redefinição do HTML para paginação da próxima página
  def next_page
    if @collection.next_page
      @template.link_to "Mostrar mais resultados",
        url(@collection.next_page), :remote => true
    end
  end

  def url(page)
    "?page=#{page}"
  end

  # Container da paginação
  def html_container(html)
    if @options[:class].eql? "pagination"
      # Por default, o atributo class do elemento HTML do endless
      # será "endless".
      @options[:class] = "endless"
    end

    tag(:div, html, container_attributes)
  end

end
