# -*- encoding : utf-8 -*-
module StatusService
  class AggregatedQuery
    attr_reader :relation
    attr_accessor :aggregator

    def initialize(aggregator, relation=Status)
      @aggregator = aggregator
      @relation = relation.where(build_conditions)
    end

    def count
      relation.count
    end

    def find_each(&block)
      relation.find_each(&block)
    end

    protected

    def build_conditions
      statusables = aggregator.perform
      statusables.reject! { |_, instances| instances.empty? }

      conditions = statusables.map do |klass_key, instances|
        ids = instances.map(&:id).join(',')
        "(statusable_type LIKE '#{klass_key.to_s.classify}' AND " \
          "statusable_id IN (#{ids}))"
      end

      conditions.join(" OR ")
    end
  end
end
