# -*- encoding : utf-8 -*-
module StatusService
  class FromHierarchyStatusQuery
    attr_reader :relation

    def initialize(entity, relation=Status)
      @entity = entity
      @relation = relation.where(build_conditions)
    end

    def count
      relation.count
    end

    def find_each(&block)
      relation.find_each(&block)
    end

    protected

    attr_reader :entity

    def build_conditions
      statusables = statuables_on_hierarchy(entity)
      statusables.reject! { |_, instances| instances.empty? }

      conditions = statusables.map do |klass_key, instances|
        ids = instances.map(&:id).join(',')
        "(statusable_type LIKE '#{klass_key.to_s.classify}' AND " \
          "statusable_id IN (#{ids}))"
      end

      conditions.join(" OR ")
    end

    def statuables_on_hierarchy(root)
      groups = { :courses => [], :spaces => [], :lectures => [] }

      case root.class.to_s
      when 'Course'
        groups[:courses] = [root]
        groups[:spaces] = root.spaces.select("spaces.id")
        groups[:lectures] = lectures_or_nothing(groups[:spaces])
      when 'Space'
        groups[:spaces] = [root]
        groups[:lectures] = lectures_or_nothing(groups[:spaces])
      when 'Lecture'
        groups[:lectures] = [root]
      end

      groups
    end

    def lectures_or_nothing(spaces)
      spaces.collect do |space|
        space.subjects.select("subjects.id").collect do |subject|
          subject.lectures.select("lectures.id")
        end
      end.flatten
    end
  end
end
