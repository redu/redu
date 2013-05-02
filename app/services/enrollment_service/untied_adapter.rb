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
        event = build_event(event_name, enrollment)
        producer.publish(event)
      end

      enrollments
    end

    def producer
      @producer ||= Untied::Publisher.adapter.producer.new
    end

    private

    def build_collection(enrollments)
      enrollments.respond_to?(:map) ? enrollments : [enrollments]
    end

    def build_event(name, payload)
      origin = Untied::Publisher.config.service_name
      Untied::Event.new(:name => name, :payload => payload, :origin => origin)
    end
  end
end
