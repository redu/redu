if ( node[:environment][:name] == "production" ) or ( node[:environment][:name] == "staging" )
  run "echo Syncing public dir with S3:"
  run "export SSL_CERT_DIR=/etc/ssl/certs && cd #{current_path} && bundle exec rake s3commit"
end
