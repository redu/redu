# -*- encoding : utf-8 -*-
module StatusService
  class StatusDependenciesEntityService
    attr_reader :statuses

    def initialize(opts={})
      @statuses = opts.delete(:statuses)
    end

    def destroy
      destroy_dependency(Answer)
      destroy_dependency(StatusUserAssociation)
      destroy_dependency(StatusResource)
    end

    private

    def destroy_dependency(klass)
      dependency_arel(klass).delete_all
    end

    def dependency_arel(klass)
      if klass == Answer
        klass.where(:in_response_to_id => statuses,
                    :in_response_to_type => "Status")
      else
        klass.where(:status_id => statuses)
      end
    end
  end
end
