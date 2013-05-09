#
# Cookbook Name:: s3cmd
# Recipe:: default
#
#
if node[:instance_role] == 'app_master'
  file_to_fetch = "http://downloads.sourceforge.net/project/s3tools/s3cmd/" \
    "#{node[:s3cmd][:version]}/s3cmd-#{node[:s3cmd][:version]}.tar.gz"

  execute "Downloading s3cmd package" do
    cwd "/tmp"
    command "wget #{file_to_fetch}"
    not_if { FileTest.exists?("/tmp/s3cmd-#{node[:s3cmd][:version]}.tar.gz") }
  end

  execute "Untarring s3cmd package" do
    command "cd /tmp; tar zxf s3cmd-#{node[:s3cmd][:version]}.tar.gz -C /opt"
    not_if { FileTest.directory?("/opt/s3cmd-#{node[:s3cmd][:version]}") }
  end

  link "/usr/bin/s3cmd" do
    to "/opt/s3cmd-#{node[:s3cmd][:version]}/s3cmd"
    not_if "test -L /usr/bin/s3cmd"
  end

  package "gnupg" do
    action :install
  end

  template "/home/deploy/.s3cfg" do
    source "config.erb"
    owner "deploy"
    group "deploy"
    variables(
      :access_key => node[:s3][:access_key],
      :secret_key => node[:s3][:secret_key],
      :gpg_command => node[:gpg][:command],
      :gpg_passphrase => node[:gpg][:passphrase]
    )
    not_if { FileTest.exists? "/home/deploy/.s3cfg" }
  end
end
