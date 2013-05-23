# -*- encoding : utf-8 -*-
class DocumentService < LectureableService
  def build(lecture=nil, &block)
    media = attrs[:media]
    Document.new do |d|
      d.attachment = media
      block.call(s) if block
    end
  end

  def authorize!(lecture)
    ability.authorize!(:upload_document, lecture)
  end
end
