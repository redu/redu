Factory.define :document do |doc|
  doc.attachment {
    File.new(
      File.join(Rails.root, "spec", "support/documents", "document_test.pdf"))
  }
end
