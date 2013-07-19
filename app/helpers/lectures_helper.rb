# -*- encoding : utf-8 -*-
module LecturesHelper
  include SpacesHelper

  def user_existent_lectures
    existent_lectures = current_user.lectures.collect do |l|
      # Não mostra os Seminars não convertidos.
      [l.name, "#{l.id.to_s}"] unless (l.lectureable.class.to_s.eql? "Seminar") and
      (not l.lectureable.state.eql? "converted")
    end
    existent_lectures.compact!
    existent_lectures
  end

  def render_player(options = {})
    options = {
      :width => '608',
      :height => '360',
      :skin => '/flash/modieus.swf',
      :flashplayer => '/flash/player.swf',
      :id => 'player',
    }.merge(options)

    result = <<-END
        jwplayer('#{options[:id]}').setup({
          'flashplayer': '/flash/player.swf',
          'file': '#{options[:youtube_url]}',
          'skin': '#{options[:skin]}',
          'controlbar': 'bottom',
          'width': '#{options[:width]}',
          'height': '#{options[:height]}'
        });
    END

    result.html_safe
  end

  # Adiciona o ícone para aula finalizada.
  def mark_lecture_icon(done)
    "icon-correct-green_16_18-after" if done
  end

  # Adiciona tooltip caso o finalizar aula esteja desativado.
  def add_tooltip_if_disabled(disable, &block)
    body = capture(&block)

    if disable
      content_tag(:div, body, rel: "tooltip", title: "Estamos" \
                  " processando esta aula, por favor, aguarde. Em instantes" \
                  " você poderá finalizá-la.")
    else
      body
    end
  end

  # Retorna a classe de ícone dependendo do tipo da aula.
  def lecture_type_class(lecture)
    case lecture.lectureable_type.to_s.downcase
    when "document" then "presentation"
    when "page" then "text-page"
    when "seminar" then "video"
    when "api::canvas" then "app"
    else lecture.lectureable_type.to_s.downcase
    end
  end

  # Retorna valor numérico (em string) correspondente a se a aula foi finalizada.
  def lecture_done_value(done)
    done ? '0' : '1'
  end
end
