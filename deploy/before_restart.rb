run "echo #{environment} abc"
if (node[:environment][:name].include?("staging"))
  run "echo Syncing public dir with S3:"
  run "bundle exec jammit-s3 --config config/assets-#{node[:environment][:name]}.yml"
  run "ln -sf config/assets-#{node[:environment][:name]}.yml config/assets.yml"
end
