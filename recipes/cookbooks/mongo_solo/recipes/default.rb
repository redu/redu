# -*- encoding : utf-8 -*-
#
# Cookbook Name:: mongo_solo
# Recipe:: default
#

if @node[:instance_role] == 'db_master'
  version = "2.2.0"

  ey_cloud_report "MongoDB" do
    message "installing mongodb #{version}"
  end

  enable_package "dev-db/mongodb-bin" do
    version version
  end

  package "dev-db/mongodb-bin" do
    version version
    action :install
  end

  execute "start MongoDB" do
    Chef::Log.info "Starting MongoDB"
    command "sudo /etc/init.d/mongodb start"
    not_if { FileTest.exists?("/var/run/mongodb/mongodb.pid") }
  end
end
