# -*- encoding : utf-8 -*-
module StatusService
  class SpaceAggregator < Struct.new(:space)
    def perform
      { spaces: [space], lectures: lectures }
    end

    private

    def lectures
      space.subjects.select("subjects.id").map do |subject|
        subject.lectures.select("lectures.id")
      end.flatten
    end
  end
end
