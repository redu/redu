FactoryGirl.define do
  factory :folder do |f|
    f.sequence(:name) {|n| "Folder #{n}" }
    f.association :user
    f.association :space
    f.parent { |file| file.space.root_folder }
    f.date_modified Time.now
  end

  factory :root_folder, :parent => :folder do |f|
    f.user nil
    f.parent nil
    f.date_modified nil
  end

  factory :complete_folder, :parent => :folder do
    after_create do |f|
      f.myfiles << Factory(:myfile, :folder => f)
    end
  end
end
