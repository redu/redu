if (Rails.env.staging? == "staging")
  run "echo Syncing public dir with S3:"
  run "bundle exec jammit-s3 --config config/assets-#{Rails.env.to_s}.yml"
  run "ln -sf config/assets-#{Rails.env.to_s}.yml config/assets.yml"
end
