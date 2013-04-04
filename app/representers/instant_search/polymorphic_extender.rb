module InstantSearch
  module PolymorphicExtender
    def self.extended(model)
      representer = representer_name_for(model)
      if representer
        model.extend(representer)
      end
    end

    def self.representer_name_for(model)
      "InstantSearch::#{model.class.to_s.split("::").last}Representer".constantize
    end
  end
end
