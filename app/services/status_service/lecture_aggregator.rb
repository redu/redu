# -*- encoding : utf-8 -*-
module StatusService
  class LectureAggregator < Struct.new(:lecture)
    def perform
      { lectures: [lecture] }
    end
  end
end
