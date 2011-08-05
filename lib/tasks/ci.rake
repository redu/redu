namespace :ci do
  task :copy_yml do
    system("cp #{Rails.root}/config/database.yml.ci #{Rails.root}/config/database.yml")
  end

  desc "Prepare CI"
  task :build => ["ci:copy_yml", "db:create", "db:migrate", "spec"] do
  end
end
