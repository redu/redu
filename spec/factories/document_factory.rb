Factory.define :document do |doc|
  doc.attachment { File.new( File.join(RAILS_ROOT, "spec", "support/documents", "document_test.pdf"))}
end
