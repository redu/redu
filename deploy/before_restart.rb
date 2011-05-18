if ( env?('production') or env?('staging') )
  sync_assets
end

def sync_assets
  run "echo Syncing public dir with S3:"
  run "export SSL_CERT_DIR=/etc/ssl/certs && cd #{current_path} && bundle exec rake s3commit"
end

def env?(environment)
  node[:environment][:name].eql?(environment)
end
