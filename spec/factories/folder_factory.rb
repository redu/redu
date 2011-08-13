Factory.define :folder do |f|
  f.sequence(:name) {|n| "Folder #{n}" }
  f.association :user
  f.association :space
  f.parent { |file| file.space.root_folder }
end
