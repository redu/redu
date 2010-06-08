module CoursesHelper
	
  def link_to_add_fields(name, f, association)
		new_object = f.object.class.reflect_on_association(association).klass.new
		fields = f.fields_for(association, new_object, :child_index => "new_#{association}") do |builder|
			render(association.to_s.singularize + "_fields", :f => builder)
		end
		link_to_function(name, h("add_fields(this, \"#{association}\", \"#{escape_javascript(fields)}\")"))
  end

  def link_to_add_lesson(name, f, association)
    new_object = f.object.class.reflect_on_association(association).klass.new
    fields = f.fields_for(association, new_object, :child_index => "new_#{association}") do |builder|
      render(association.to_s.singularize + "_form", :f => builder)
    end
    link_to_function(name, h("add_fields(this, \"#{association}\", \"#{escape_javascript(fields)}\")"))
  end
  
	
	def type_class(resource)
			icon = case resource.attachment_content_type
			when "clipping" then 'clipping'
			when "application/vnd.ms-powerpoint" then 'ppt'
			when "application/msword" then 'word'
	    when "application/rtf" then 'word'
      when "text/plain" then 'word' 
			when "application/pdf" then 'pdf'
			else ''
			end
			
	end
end
