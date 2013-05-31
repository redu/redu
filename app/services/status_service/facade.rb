# -*- encoding : utf-8 -*-
module StatusService
  class Facade
    include Singleton

    def destroy_status(statusable)
      status_service = StatusEntityService.new(statusable: statusable)

      status_dependencies_service = StatusDependenciesEntityService.
        new(statuses: status_service.statuses)
      status_dependencies_service.destroy

      status_service.destroy
    end

    def answer_status(status, attributes, &block)
      answer = answer_service.create(status, attributes, &block)
      AnswerService::AnswerNotificationService.new(answer).deliver if answer

      answer
    end

    private

    def answer_service
      AnswerService::AnswerEntityService.new
    end
  end
end
