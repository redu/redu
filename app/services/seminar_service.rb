class SeminarService
  def create(attrs, &block)
    build(attrs, &block)
  end

  def build(attrs, &block)
    media = attrs[:media]
    Seminar.new do |s|
      if media =~ /youtube.com.*(?:\/|v=)([^&$]+)/
        s.external_resource_url = media
      else
        s.original = media
      end
      block.call(s) if block
    end
  end
end
