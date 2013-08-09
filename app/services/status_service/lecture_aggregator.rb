# -*- encoding : utf-8 -*-
module StatusService
  class LectureAggregator
    def initialize(lecture)
      @lecture = lecture
    end

    def perform
      { Lecture: [lecture.id] }
    end

    private

    attr_accessor :lecture
  end
end
