module Roar::Rails
  module Responder
    def extend_with_representer!(resource, representer=nil)
      if const_exists? representer_name(resource)
        representer ||= representer_for_resource(resource)
        resource.extend(representer)
      end
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
      representer_name(resource).constantize
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
