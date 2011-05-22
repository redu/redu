if (node[:environment][:name].include?("staging"))
  run "echo Syncing public dir with S3:"
  run "bundle exec jammit-s3 --config config/assets-#{node[:environment][:name]}.yml"
  run "cd config; ln -sf assets-#{node[:environment][:name]}.yml assets.yml"
end
