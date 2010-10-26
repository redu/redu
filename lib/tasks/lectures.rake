namespace :courses do
  desc "Destroy all courses"
  task :remove_all => :environment do
    Course.destroy_all
  end
end