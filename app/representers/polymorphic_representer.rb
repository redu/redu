module PolymorphicRepresenter
  def self.extended(model)
    if representer = representer_name_for(model)
      model.extend(representer)
    end
  end

  def self.representer_name_for(model)
    representer_name = "#{model.class.to_s.split("::").last}Representer"
    if Object.const_defined?(representer_name)
      representer_name.constantize
    else
      nil
    end
  end
end
