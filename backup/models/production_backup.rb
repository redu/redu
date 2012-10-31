# encoding: utf-8
s3_config = YAML.load_file('./config/s3.yml')['production']
# Necessário, pois contém código ruby
require 'erb'
db_config = YAML.load(ERB.new(IO.read('./config/database.yml')).result)['production']

##
# Backup Generated: production_backup
# Once configured, you can run the backup with the following command:
#
# $ backup perform -t production_backup -r backup
#
Backup::Model.new(:production_backup, 'Backup of the production database') do
  ##
  # Split [Splitter]
  #
  # Split the backup file in to chunks of 250 megabytes
  # if the backup file size exceeds 250 megabytes
  #
  split_into_chunks_of 4000

  ##
  # MySQL [Database]
  #
  database MySQL do |db|
    # To dump all databases, set db.name = :all (or leave blank)
    db.name               = db_config['database']
    db.username           = db_config['username']
    db.password           = db_config['password']
    db.host               = db_config['host']
    db.port               = 3306
    db.socket             = "/tmp/mysql.sock"
    db.skip_tables        = ["sessions"]
    db.additional_options = ["--quick", "--single-transaction"]
  end

  ##
  # Amazon Simple Storage Service [Storage]
  #
  # Available Regions:
  #
  #  - ap-northeast-1
  #  - ap-southeast-1
  #  - eu-west-1
  #  - us-east-1
  #  - us-west-1
  #
  store_with S3 do |s3|
    s3.access_key_id     = s3_config['access_key_id']
    s3.secret_access_key = s3_config['secret_access_key']
    s3.region            = "us-east-1"
    s3.bucket            = "redu-backup"
    s3.path              = "/"
    s3.keep              = 20
  end

  encrypt_with OpenSSL do |encryption|
    encryption.password = 'NPR30nursed'
    encryption.base64 = true
    encryption.salt = true
  end

  ##
  # Mail [Notifier]
  #
  # The default delivery method for Mail Notifiers is 'SMTP'.
  # See the Wiki for other delivery options.
  # https://github.com/meskyanichi/backup/wiki/Notifiers
  #
  #notify_by Mail do |mail|
  #  mail.on_success           = true
  #  mail.on_warning           = true
  #  mail.on_failure           = true

  #  mail.from                 = "no-reply@redu.com.br"
  #  mail.to                   = "receiver@email.com"
  #  mail.address              = "smtp.gmail.com"
  #  mail.port                 = 587
  #  mail.domain               = "redu.com.br"
  #  mail.user_name            = "no-reply@redu.com.br"
  #  mail.password             = "penn441\boob"
  #  mail.authentication       = "plain"
  #  mail.enable_starttls_auto = true
  #end

end
