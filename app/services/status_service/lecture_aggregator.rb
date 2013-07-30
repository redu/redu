# -*- encoding : utf-8 -*-
module StatusService
  class LectureAggregator < Struct.new(:lecture)
    def perform
      { Lecture: [lecture.id] }
    end
  end
end
