if (environment.include?("staging"))
  run "cd config; ln -sf assets-#{environment}.yml assets.yml"
  run "bundle exec jammit-s3 "
end
