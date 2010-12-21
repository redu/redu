module LecturesHelper
  include SpacesHelper
	
  def link_to_add_fields(name, f, association, type = nil)
		new_object = f.object.class.reflect_on_association(association).klass.new
		fields = f.fields_for(association, new_object, :child_index => "new_#{association}") do |builder|
			render(association.to_s.singularize + "_fields", :f => builder)
		end
		link_to_function(name, h("add_fields(this, \"#{association}\", \"#{escape_javascript(fields)}\", \"#{type}\")"))
  end

  def link_to_add_lesson(name, f, lesson_type)
    
    new_object = f.object.class.reflect_on_association(:lessons).klass.new
    fields = f.fields_for(:lessons, new_object, :child_index => "new_#{:lessons}") do |builder|
#      case lesson_type
#      when 'page'
#        render("form_lesson_"  + lesson_type, :form_lesson => builder)
#      when 'seminar'
#        render("form_lesson_"  + lesson_type, :form_lesson => builder)
#      end
        render("form_lesson_"  + lesson_type, :form_lesson => builder)
    end
    link_to_function(name, h("add_fields(this, \"#{:lessons}\", \"#{escape_javascript(fields)}\", \"#{lesson_type}\")"))
  end
  
  def lesson_icon(lesson)
    
    case lesson.lesson_type
      when 'Page'
        image_tag 'icons/iclass.gif', :title => "Texto"
      when 'ExternalObject'
         image_tag 'icons/objects.png', :title => "Objetos"
     when 'Seminar'
        image_tag 'icons/seminar.gif', :title => "Vídeo"
    end
  end
#  def link_to_add_lesson(name, f, association)
#    new_object = f.object.class.reflect_on_association(association).klass.new
#    fields = f.fields_for(association, new_object, :child_index => "new_#{association}") do |builder|
#      render("form_"  + association.to_s.singularize, :f => builder)
#    end
#    link_to_function(name, h("add_fields(this, \"#{association}\", \"#{escape_javascript(fields)}\")"))
#  end

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
  

	
end
