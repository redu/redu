# -*- encoding : utf-8 -*-
module StatusService
  class FromHierarchyStatusQuery
    # Constrói as condições de busca de status dentro da hierarquia. Aceita
    # Course, Space e Lecture como raiz
    def build_conditions(entity)
      statusables = statuables_on_hierarchy(entity)
      conditions = []

      statusables.each do |key, val|
        next if val.empty?

        ids = val.collect { |s| s.id }.join(',')
        conditions << "(statusable_type LIKE '#{key.to_s.classify}' AND " + \
          "statusable_id IN (#{ids}))"
      end

      return conditions.join(" OR ")
    end

    protected

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
