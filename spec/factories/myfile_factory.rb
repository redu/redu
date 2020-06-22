# -*- encoding : utf-8 -*-
FactoryBot.define do
  factory :myfile do |m|
    m.sequence(:attachment_file_name) { |n| "File #{n}" }
    m.attachment_content_type "image/jpeg"
    m.attachment_file_size 40000
    m.attachment_updated_at Time.now
    m.association :folder
    m.association :user
  end
end
