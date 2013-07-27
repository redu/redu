module StatusService
  class CourseAggregator < Struct.new(:course)
    def perform
      { courses: [course], spaces: spaces, lectures: lectures }
    end

    private

    def spaces
      course.spaces.select("spaces.id")
    end

    def lectures
      course.spaces.map do |space|
        space.subjects.select("subjects.id").collect do |subject|
          subject.lectures.select("lectures.id")
        end
      end.flatten
    end
  end
end
