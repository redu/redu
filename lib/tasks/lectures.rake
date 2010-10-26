namespace :courses do
  desc "Destroy all courses"
  task :remove_all => :environment do
    Lecture.destroy_all
  end
end
