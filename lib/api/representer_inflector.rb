module Api
  module RepresenterInflector
    extend ActiveSupport::Concern

    def representer_for_resource(resource)
      representer_name(resource).constantize
    end

    def representer_name(resource)
      "Api::#{resource.class.to_s.split("::").last}Representer"
    end
  end
end
