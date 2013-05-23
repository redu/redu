module Api
  class PageSanitizer < Struct.new(:content)
    def sanitize
      reader.fragment(content).text
    end

    private

    def reader
      doc = Nokogiri::HTML::Document.new
      doc.encoding = 'UTF-8'
      doc
    end
  end
end
