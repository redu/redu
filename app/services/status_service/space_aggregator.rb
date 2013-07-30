# -*- encoding : utf-8 -*-
module StatusService
  class SpaceAggregator < Struct.new(:space)
    def perform
      @values ||= { Space: [space.id], Lecture: lectures_ids }
    end

    private

    def lectures_ids
      subjects_ids = space.subjects.values_of(:id)
      Lecture.by_subjects(subjects_ids).values_of(:id)
    end
  end
end
