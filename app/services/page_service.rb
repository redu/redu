class PageService < LectureableService
  def build(&block)
    Page.new do |p|
      p.body = attrs[:content]
    end
  end
end
