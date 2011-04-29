module LecturesHelper
  include SpacesHelper

  def link_to_add_fields(name, f, association, type = nil)
		new_object = f.object.class.reflect_on_association(association).klass.new
		fields = f.fields_for(association, new_object, :child_index => "new_#{association}") do |builder|
			render(association.to_s.singularize + "_fields", :f => builder)
		end
		link_to_function(name, h("add_fields(this, \"#{association}\", \"#{escape_javascript(fields)}\", \"#{type}\")"))
  end

  def render_lecture
    case @lecture.lectureable_type
    when 'Seminar'
      render :partial => "seminar"
    when 'InteractiveClass'
      render :partial => "interactive"
    when 'Page'
      render :partial => "page"
    when 'Document'
      render :partial => "document"
    end
  end

  def user_existent_lectures
    existent_lectures = current_user.lectures.collect do |l|
      # Não mostra os Seminars não convertidos.
      [l.name, "#{l.id.to_s}"] unless (l.lectureable.class.to_s.eql? "Seminar") and
      (not l.lectureable.state.eql? "converted")
    end
    existent_lectures.compact!
    existent_lectures
  end


end
