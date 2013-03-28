class DocumentService
  def create(attrs, &block)
    build(attrs, &block)
  end

  def build(attrs, &block)
    media = attrs[:media]
    Document.new do |d|
      d.attachment = media
      block.call(s) if block
    end
  end
end
