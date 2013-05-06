module Untied
  module Publisher
    class Queue
      def enqueue(event_name, model)
        job = PublishEventJob.new(event_name, model.class.to_s, model.id)
        delayed_job.enqueue(job, :queue => :vis)
      end

      private

      def delayed_job
        Delayed::Job
      end
    end
  end
end
