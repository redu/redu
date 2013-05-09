module Untied
  module Publisher
    class PublishEventJob
      attr_reader :event_name, :class_name, :model_id

      def initialize(event_name, class_name, id_model_or_hash)
        @event_name = event_name
        @class_name = class_name

        if id_model_or_hash.is_a? Hash
          @payload = id_model_or_hash
        elsif id_model_or_hash.is_a? Fixnum
          @model_id = id_model_or_hash.to_i
        else
          @model_id = id_model_or_hash.id
        end
      end

      def perform
        producer.publish(event)
      end

      def producer
        @@producer ||= Untied::Publisher.adapter.producer.new
      end

      private

      def event
        origin = Untied::Publisher.config.service_name
        Untied::Event.new(:name => event_name, :payload => payload,
                          :origin => origin)
      end

      def payload
        @payload ||= class_name.constantize.find(model_id)
      end
    end
  end
end
