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

    # Retrocompatibilidade: Rails 3.2+ empacota erros em um hash do
    # tipo { :errors => ... }
    # https://github.com/rails/rails/commit/a0a68ecbb22dacf5111198e72e3a803e7c965881#actionpack/lib/action_controller/metal/responder.rb
    def json_resource_errors
      resource.errors
    end
  end
end
