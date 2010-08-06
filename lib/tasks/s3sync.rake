#--------SETUP
#KEYS: http://aws-portal.amazon.com/gp/aws/developer/account/index.html?action=access-key
#insert here

OPTIONS = {
  'AWS_ACCESS_KEY' => 'AKIAIRKVQDTWT2NN4J4Q',
  'AWS_SECRET_ACCESS_KEY' => 'fd34osN7Is0gckllFl8OxZgOuZieeaiSHZg1TpAM',
  'BUCKET_NAME' => 'redu_assets',
  'FILES' => {'public/' => ''}
}

# OR use a config (s3sync.yml) example: 
# aws_access_key: 11111111111111111111111
# aws_secret_access_key: 222222222222222222222
# bucket_name: testbucket
# files:
#   public/: static #upload all public files ito the static folder


#Supplied AS IS, no warranty at all
#Use/Copy/Modify as u like
#
#bugs/suggestions -> code.google.com/p/rakes3sync






#--------CODE

#Installation/Options etc
module RakeS3Sync

  #return options + merge with config if available
  def self.options
    require 'yaml'
    
    path = 'lib/tasks/s3sync.yml'
    if File.exists? path
      config = YAML.load_file path
      config.each_pair do |key, value|
        #replace all empty options
        OPTIONS[key.upcase] = value if ( !OPTIONS[key.upcase] or OPTIONS[key.upcase].length == 0 )
      end
    else
      puts "NOTICE: No Config found (#{path})"
    end
   
    OPTIONS
  end
   
  #download and install all required libaries/certificates
  def self.install_required
    unless File.exists? 'lib/s3sync/s3sync.rb'
      puts 'DOWNLOADING s3ync'
      `curl http://s3.amazonaws.com/ServEdge_pub/s3sync/s3sync.tar.gz`
      `tar xvzf s3sync.tar.gz`
      `mv s3sync lib/`
      `rm s3sync.tar.gz`
    end
    
    unless File.exists? 'lib/s3sync/s3sync_certificate'
      puts 'DOWNLOADING Certificate'
      `curl http://rakes3sync.googlecode.com/svn/trunk/s3sync_certificate`
      `mv s3sync_certificate lib/s3sync/`
    end
  end
    
  #variables that need to be exported for s3sync
  def self.export_cmd
    o = self::options
    "
    export AWS_ACCESS_KEY_ID=#{o['AWS_ACCESS_KEY']};
    export AWS_SECRET_ACCESS_KEY=#{o['AWS_SECRET_ACCESS_KEY']};
    export SSL_CERT_FILE=lib/s3sync/s3sync_certificate;
    "
  end
  
  #checks if files are entered
  def self.check_options_files
    if(!OPTIONS['FILES'] or OPTIONS['FILES'].length==0) then
      puts 'NOTHING TO DO, specify files in s3sync.rake or s3sync.yml'
      exit
    end
  end
  
  #fill & multiply commands 
  # -replace source/destination placeholders
  def self.build_cmds cmd
    o = self::options
    out = []
    
    o['FILES'].each_pair do |source, destination|
      out.push(cmd.sub('_SOURCE_',source.to_s).sub('_DESTINATION_',destination.to_s))#to_s in case of nil
    end
    out.join ";\n"
  end
end #module

#--------TASKS
desc "Create bucket"
task :s3create do
  require 'S3'
  o = RakeS3Sync.options
  
  conn = S3::AWSAuthConnection.new(o['AWS_ACCESS_KEY'], o['AWS_SECRET_ACCESS_KEY'], false)
  conn.create_bucket(o['BUCKET_NAME'])
  puts "BUCKET #{o['BUCKET_NAME']} "
end

desc "Upload changes to s3"
task :s3commit do
  RakeS3Sync::install_required
  RakeS3Sync::check_options_files
  o = RakeS3Sync.options
  
  puts 'STARTING SYNC'
  cmds = RakeS3Sync::build_cmds("ruby lib/s3sync/s3sync.rb -r --ssl --delete _SOURCE_ #{o['BUCKET_NAME']}:_DESTINATION_")
  `
  #{RakeS3Sync::export_cmd}
  #{cmds}
  `
end

desc "Download from S3"
task :s3update do
  RakeS3Sync::install_required
  RakeS3Sync::check_options_files
  o = RakeS3Sync.options
    
  puts 'STARTING UPDATE'
  cmds = RakeS3Sync::build_cmds("ruby lib/s3sync/s3sync.rb -r --ssl --delete #{o['BUCKET_NAME']}:_DESTINATION_ _SOURCE_")
  `
  #{RakeS3Sync::export_cmd}  
  #{cmds}
  `
end
