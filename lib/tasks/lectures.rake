namespace :lectures do
  desc "Destroy all lectures"
  task :remove_all => :environment do
    Lecture.destroy_all
  end
end
