# -*- encoding : utf-8 -*-
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
      enrolls = includes_relationships_if_arel(enrollments)
      vis_client.notify_delayed(url, message.to_s, enrolls)
    end

    def includes_relationships_if_arel(enrollments)
      if enrollments.is_a? ActiveRecord::Relation
        enrollments.includes(subject: [space: :course])
      else
        enrollments
      end
    end
  end
end
