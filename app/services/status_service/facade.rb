# -*- encoding : utf-8 -*-
module StatusService
  class Facade
    include Singleton

    def destroy_status(statusable)
      status_dependencies_service = StatusDependenciesEntityService.
        new(statusable: statusable)
      status_dependencies_service.destroy

      status_service = StatusEntityService.new(statusable: statusable)
      status_service.destroy
    end
  end
end
