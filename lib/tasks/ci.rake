namespace :ci do
  task :copy_yml do
    system("cp #{Rails.root}/config/database.yml.ci #{Rails.root}/config/database.yml")
  end

  task :rspec do
    system("bundle exec rake -s spec; echo $?")
  end

  desc "Prepare CI"
  task :build => ["ci:copy_yml", "db:create", "db:migrate", "ci:rspec"] do
  end
end
