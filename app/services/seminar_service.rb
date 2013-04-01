class SeminarService < LectureableService
  def build(&block)
    media = attrs[:media]
    Seminar.new do |s|
      if media =~ /youtube.com.*(?:\/|v=)([^&$]+)/
        s.external_resource_url = media
      else
        s.original = media
        s.external_resource_type = 'upload'
      end
      block.call(s) if block
    end
  end

  def authorize!(lecture)
    ability.authorize!(:upload_multimedia, lecture)
  end

  def process!
    @lectureable.transcode if @lectureable.need_transcoding?
  end
end
