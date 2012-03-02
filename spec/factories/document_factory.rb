Factory.define :document do |doc|
  doc.attachment_file_name 'Document'
  doc.attachment_content_type 'application/pdf'
  doc.attachment_file_size 2.megabytes
end
