# -*- encoding : utf-8 -*-
class VideoTranscodingJob < Struct.new(:lecture_resource_id)
  def perform
    seminar = Seminar.find(lecture_resource_id)
    if seminar.video?
      seminar.convert!
      seminar.ready!
    else
      seminar.fail!
    end
  end
end
