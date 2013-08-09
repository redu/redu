# -*- encoding : utf-8 -*-
module StatusService
  class SpaceHierarchyAggregator
    def initialize(space)
      @space = space
    end

    def build
      @values ||= { Space: [space.id], Lecture: lectures_ids }
    end

    private

    attr_accessor :space

    def lectures_ids
      subjects_ids = space.subjects.values_of(:id)
      Lecture.by_subjects(subjects_ids).values_of(:id)
    end
  end
end
