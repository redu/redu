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
end
