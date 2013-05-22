# -*- encoding : utf-8 -*-
class PageService < LectureableService
  def build(lecture=nil, &block)
    Page.new do |p|
      p.body = attrs[:content]
    end
  end
end
