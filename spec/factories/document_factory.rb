FactoryGirl.define do
  factory :document do
    attachment_file_name 'Document'
    attachment_content_type 'application/pdf'
    attachment_file_size 2.megabytes
  end

  factory :document_with_image, :parent => :document do
    attachment_file_name 'Image'
    attachment_content_type 'image/jpeg'
    attachment_file_size 2.megabytes
  end
end
