module EnrollmentService
  class VisAdapter
    attr_reader :vis_client, :url

    def initialize(opts={})
      @vis_client = opts[:vis_client] || VisClient
      @url = opts[:url] || "/hierarchy_notifications.json"
    end

    def notify_enrollment_creation(enrollments)
      notify(:enrollment, enrollments)
    end

    def notify_enrollment_removal(enrollments)
      notify(:remove_enrollment, enrollments)
    end

    def notify_remove_subject_finalized(enrollments)
      notify(:remove_subject_finalized, enrollments)
    end

    def notify_subject_finalized(enrollments)
      notify(:subject_finalized, enrollments)
    end

    private

    def notify(message, enrollments)
      vis_client.notify_delayed(url, message.to_s, enrollments)
    end
  end
end
