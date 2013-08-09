# -*- encoding : utf-8 -*-
module StatusService
  class LectureHierarchyAggregator
    def initialize(lecture)
      @lecture = lecture
    end

    def build
      { Lecture: [lecture.id] }
    end

    private

    attr_accessor :lecture
  end
end
