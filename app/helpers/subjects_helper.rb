module SubjectsHelper

  #    def link_to_add_fields(name, f, association, type = nil)
  #    new_object = f.object.class.reflect_on_association(association).klass.new
  #    fields = f.fields_for(association, new_object, :child_index => "new_#{association}") do |builder|
  #      render(association.to_s.singularize + "_fields", :f => builder)
  #    end
  #    link_to_function(name, h("add_fields(this, \"#{association}\", \"#{escape_javascript(fields)}\", \"#{type}\")"))
  #  end

  def to_pt_BR_format(datetime)
    datetime.strftime("%d/%m/%Y %H:%M") unless datetime.nil?
  end
end
