# -*- encoding : utf-8 -*-
FactoryGirl.define do
  factory :seminar_youtube, :class => :seminar do
    external_resource_url 'http://www.youtube.com/watch?v=LADHwoN2LMM'
  end

  factory :seminar_upload, :class => :seminar do
    original_file_name 'Video'
    original_content_type 'video/mpeg'
    original_file_size 5.megabytes
  end
end
