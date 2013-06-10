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

  def mark_lecture_icon(done)
    if done
      "icon-class-green_16_18-before"
    else
      "icon-class-gray_16_18-before"
    end
  end

  def disable_label_if(disable)
    "disabled" if disable
  end

  def add_tiptip_if_disabled(disable, &block)
    body = capture(&block)

    if disable
      content_tag(:span, body, :class => "tiptip", :title => "Estamos" \
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
    else lecture.lectureable_type.to_s.downcase
    end
  end
end
