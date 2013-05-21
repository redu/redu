# -*- encoding : utf-8 -*-
module EnrollmentService
  class UntiedAdapter
    def notify_after_create(enrollments)
      produce_event(:after_create, enrollments)
    end

    def notify_after_destroy(enrollments)
      produce_event(:after_destroy, enrollments)
    end

    def produce_event(event_name, enrollments)
      enrollments = build_collection(enrollments)

      enrollments.each do |enrollment|
        queue.enqueue(event_name, enrollment)
      end
      queue.commit

      enrollments
    end

    def queue
      @queue ||= Untied::Publisher::QueueProxy.new
    end

    private

    def build_collection(enrollments)
      enrollments.respond_to?(:map) ? enrollments : [enrollments]
    end
  end
end
