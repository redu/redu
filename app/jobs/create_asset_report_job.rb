class CreateAssetReportJob
  attr_accessor :lecture_id

  def initialize(lecture_id)
    @lecture_id = lecture_id
  end

  def perform
    lecture = Lecture.find_by_id(@lecture_id)
    lecture.create_asset_report if lecture
  end
end
