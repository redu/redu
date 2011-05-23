if environment.include?("production")
  run "bundle exec jammit-s3 "
end
