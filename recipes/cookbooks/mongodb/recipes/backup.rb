# -*- encoding : utf-8 -*-
#
# Cookbook Name:: mongodb
# Recipe:: backup
#

if @node[:instance_role] == 'db_master'
  ey_cloud_report "mongodb" do
    message "configuring backup"
  end

  template "/usr/local/bin/mongo-backup" do
    source "mongo-backup.rb.erb"
    owner "root"
    group "root"
    mode 0700
    variables({
      :secret_key => @node[:aws_secret_key],
      :id_key => @node[:aws_secret_id],
      :env => @node[:environment][:name],
    })
  end

  if @node[:environment][:framework_env] == 'production'
    cron "mongo-backup" do
      hour "22"
      minute "0"
      command "/usr/local/bin/mongo-backup"
    end
  end
else
  cron "mongo-backup" do
    action :delete
  end
end

