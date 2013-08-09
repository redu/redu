# -*- encoding : utf-8 -*-
module StatusService
  class AggregatedQuery
    attr_accessor :aggregator

    def initialize(aggregator, relation=Status)
      @aggregator = aggregator
      @relation = relation
    end

    def relation
      @relation.where(build_conditions)
    end

    protected

    def build_conditions
      statusables = aggregator.build
      statusables.reject! { |_, ids| ids.empty? }

      conditions = statusables.map do |klass, ids|
        "(statusable_type LIKE '#{klass}' AND " \
          "statusable_id IN (#{ids.join(",")}))"
      end

      conditions.join(" OR ")
    end
  end
end
