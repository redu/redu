class CreateAssetReportJob
  # Cria asset_report para todos usuários matriculado no subject
  attr_accessor :lecture_id

  def initialize(opts)
    @lecture_id = opts[:lecture_id]
  end

  def perform
    lecture = Lecture.find_by_id(@lecture_id)
    lecture.create_asset_report if lecture
  end
end
