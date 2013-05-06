module Untied
  module Publisher
    class QueueProxy
      def enqueue(event_name, model)
        queue = select_queue(event_name)
        queue.enqueue(event_name, model)
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

      def batch_queue
        @batch_queue ||= Untied::Publisher::BatchQueue.new
      end

      def simple_queue
        @simple_queue ||= Untied::Publisher::Queue.new
      end

    end
  end
end
