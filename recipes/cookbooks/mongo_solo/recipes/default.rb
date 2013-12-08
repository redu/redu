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

  execute "enable mongodb" do
    command "rc-update add mongodb default"
    action :run
  end

  execute "start mongodb" do
    Chef::Log.info "Starting MongoDB"
    command "/etc/init.d/mongodb restart"
    action :run
    not_if "/etc/init.d/mongodb status"
  end
end
