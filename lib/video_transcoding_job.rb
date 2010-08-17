class VideoTranscodingJob < Struct.new(:course_resource_id)
  def perform
    seminar = Seminar.find(course_resource_id)
    if seminar.video?
      seminar.convert!
      seminar.ready!
    else
      seminar.fail!
    end
  end
end