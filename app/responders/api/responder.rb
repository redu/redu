module Api
  module Responder
    include Api::RepresenterInflector

    def extend_with_representer!(resource, representer=nil)
      representer ||= representer_for_resource(resource)
      return resource.extend(representer) if representer
      resource
    end

    def display(resource, given_options={})
      representer = options.delete(:represent_with)

      if resource.respond_to?(:map!)
        resource.map! do |r|
          extend_with_representer!(r, representer)
          r.to_hash
        end
      else
        extend_with_representer!(resource, representer)
      end
      super
    end
  end
end
