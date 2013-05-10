on_app_master do
  if environment.include?("production")
    run "bundle exec jammit-s3 --base-url http://redu-assets.s3.amazonaws.com/ "
  end
end
