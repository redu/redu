module StatusService
  class CourseAggregator
    def initialize(course)
      @course = course
    end

    def perform
      @values ||= { Course: [course.id], Space: spaces_ids,
                    Lecture: lectures_ids }
    end

    private

    attr_accessor :course

    def spaces_ids
      course.spaces.values_of(:id)
    end

    def lectures_ids
      subjects_ids = Subject.where(space_id: spaces_ids).values_of(:id)
      Lecture.by_subjects(subjects_ids).values_of(:id)
    end
  end
end
