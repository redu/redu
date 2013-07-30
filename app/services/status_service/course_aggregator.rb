module StatusService
  class CourseAggregator < Struct.new(:course)
    def perform
      @values ||= { Course: [course.id], Space: spaces_ids,
                    Lecture: lectures_ids }
    end

    private

    def spaces_ids
      course.spaces.values_of(:id)
    end

    def lectures_ids
      subjects_ids = Subject.where(space_id: spaces_ids).values_of(:id)
      Lecture.by_subjects(subjects_ids).values_of(:id)
    end
  end
end
