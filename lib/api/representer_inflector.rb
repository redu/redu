module Api
  module RepresenterInflector
    extend ActiveSupport::Concern

    module InstanceMethods
      def representer_for_resource(resource)
        representer = representer_name(resource)
        representer.constantize if const_exists? representer
      end
    end

    def representer_name(resource)
      "#{resource.class.to_s.split("::").last}Representer"
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
