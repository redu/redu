module EnrollmentService
  module Jobs
    class LinkedJob
      def perform
        env = execute || {}
        next_job = build_next_job(env)

        enqueue(next_job)
      end

      def execute; end

      def build_next_job(env)
        Rails.logger.info "#{self.class} defines no next job. Nothing to do."
        nil
      end

      def facade
        Facade.instance
      end

      def options
        @options ||= LinkedJobOptions.new
      end

      private

      def enqueue(job=nil)
        Delayed::Job.enqueue(job, :queue => "hierachy-associations") if job
      end
    end
  end
end
