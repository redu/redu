module Untied
  module Publisher
    class QueueProxy
      # Adiciona evento na fila apropriada:
      #   - se event_name for :after_destroy utiliza Untied::Publisher::Queue
      #     com uma representação serializada do modelo
      #   - se event_name não for after_destroy utiliza
      #     Untied::Publisher::BatchQueue
      def enqueue(event_name, model)
        queue = select_queue(event_name)
        payload = build_payload(event_name, model)

        queue.enqueue(event_name, payload)
      end

      def commit
        batch_queue.commit unless batch_queue.empty?
      end

      private

      def select_queue(event_name)
        case event_name.to_sym
        when :after_destroy then simple_queue
        else
          batch_queue
        end
      end

      def build_payload(event_name, model)
        case event_name.to_sym
        when :after_destroy
          hash = {}
          hash["#{model.class.to_s.underscore}"] = model.attributes
          hash
        else
          model
        end
      end

      def batch_queue
        @batch_queue ||= Untied::Publisher::BatchQueue.new
      end

      def simple_queue
        @simple_queue ||= Untied::Publisher::Queue.new
      end

    end
  end
end
