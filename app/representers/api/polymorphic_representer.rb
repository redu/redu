module Api
  module PolymorphicRepresenter
    extend Api::RepresenterInflector

    def self.extended(model)
      if representer = representer_name_for(model)
        model.extend(representer)
      end
    end

    def self.representer_name_for(model)
      name = representer_name(model)
      if const_exists?(name)
        name.constantize
      else
        nil
      end
    end
  end
end
