module Roar::Rails
  module Responder
    def extend_with_representer!(resource, representer=nil)
      representer ||= representer_for_resource(resource)
      resource.extend(representer) if representer
    end

    def display(resource, given_options={})
      if resource.respond_to?(:map!)
        resource.map! do |r|
          extend_with_representer!(r)
          r.to_hash
        end
      else
        extend_with_representer!(resource, options.delete(:with_representer))
      end
      super
    end

    private

    def representer_for_resource(resource)
      representer = representer_name(resource)
      representer.constantize if const_exists? representer
    end

    def representer_name(resource)
      (resource.class.name + "Representer")
    end

    def const_exists?(class_name)
      begin
        Module.const_get(class_name)
        return true
      rescue NameError
        return false
      end
    end
  end
end
