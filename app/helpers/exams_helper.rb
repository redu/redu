module ExamsHelper
  include SchoolsHelper
  
  def seconds_to_time(number_of_seconds)
    [ number_of_seconds / 3600, number_of_seconds / 60 % 60, number_of_seconds % 60 ].map{ |t| t.to_s.rjust(2, '0') }.join(':')
  end
  
  
 def link_to_remove_fields(name, f)
    f.hidden_field(:_destroy) + link_to_function(name, "remove_fields(this)")
  end
  
  def link_to_add_fields(name, f, association, type)
    new_object = f.object.class.reflect_on_association(association).klass.new
    fields = f.fields_for(association, new_object, :child_index => "new_#{association}") do |builder|
      render(association.to_s.singularize + "_fields", :f => builder)
    end
    link_to_function(name, h("add_fields(this, \"#{association}\", \"#{escape_javascript(fields)}\", \"#{type}\")"))
  end
  
end
