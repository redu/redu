run "echo Syncing public dir with S3:"
run "export SSL_CERT_DIR=/etc/ssl/certs && cd #{current_path} && bundle excec s3commit"