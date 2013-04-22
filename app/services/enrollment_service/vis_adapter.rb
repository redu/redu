module EnrollmentService
  class VisAdapter
    attr_reader :vis_client, :url

    def initialize(opts={})
      @vis_client = opts[:vis_client] || VisClient
      @url = opts[:url] || "/hierarchy_notifications.json"
    end

    def notify_enrollment_creation(enrollments)
      vis_client.notify_delayed(url, "enrollment", enrollments)
    end

    def notify_enrollment_removal(enrollments)
      vis_client.notify_delayed(url, "remove_enrollment", enrollments)
    end

    def notify_graduated_enrollment_removal(enrollments)
      vis_client.notify_delayed(url, "remove_subject_finalized", enrollments)
    end
  end
end
