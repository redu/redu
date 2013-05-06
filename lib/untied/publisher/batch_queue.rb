module Untied
  module Publisher
    class BatchQueue < Untied::Publisher::Queue
      def enqueue(*args)
        events << args
      end

      def commit
        jobs.map { |job| delayed_job.enqueue(job, :queue => :general) }
        events.clear
      end

      private

      def delayed_job
        Delayed::Job
      end

      def jobs
        job_groups = by_event_name_and_class
        job_groups.map do |((event_name, class_name), events)|
          ids = events.map { |(_, model)| model.id }
          job = EnqueuePublishEventJob.new(event_name, class_name, ids)
        end
      end

      def by_event_name_and_class
        events.group_by { |event_name, model| [event_name, model.class.to_s] }
      end

      def events
        @events ||= []
      end
    end
  end
end
