module Untied
  module Publisher
    class PublishEventJob < Struct.new(:event_name, :class_name, :id)
      def perform
        producer.publish(event)
      end

      def producer
        @producer ||= Untied::Publisher.adapter.producer.new
      end

      private

      def event
        origin = Untied::Publisher.config.service_name
        Untied::Event.new(:name => event_name, :payload => payload,
                          :origin => origin)
      end

      def payload
        class_name.constantize.find(id)
      end
    end
  end
end
