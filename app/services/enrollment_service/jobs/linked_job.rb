# -*- encoding : utf-8 -*-
module EnrollmentService
  module Jobs
    # Permite a criação de Jobs ligados ligados entre sí.
    class LinkedJob
      def perform
        env = execute || {}
        next_job = build_next_job(env)

        enqueue(next_job)
      end

      # Deve ser implementado na classe concreta. Deve retornar um Hash
      # que será passado para #build_next_job
      def execute; end

      # Dever retornar o próximo Job a ser enfileirado. Recebe o Hash retornado
      # em #execute
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
        Delayed::Job.enqueue(job, queue: "hierarchy-associations") if job
      end
    end
  end
end
