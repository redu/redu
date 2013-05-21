# -*- encoding : utf-8 -*-
module Untied
  module Publisher
    class EnqueuePublishEventJob < Struct.new(:event_name, :class_name, :ids)
      def perform
        ids.each do |id|
          job = PublishEventJob.new(event_name, class_name, id)
          enqueue(job)
        end
      end

      private

      def enqueue(job)
        Delayed::Job.enqueue(job, :queue => "vis")
      end
    end
  end
end
