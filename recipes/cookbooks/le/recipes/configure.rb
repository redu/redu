#
# Cookbook Name:: le
# Recipe:: configure
#

execute "le register --account-key" do
  command "le register --account-key #{node[:le_api_key]}"
  action :run
  not_if { File.exists?('/etc/le/config') }
end

# Faz logentries seguir os arquivos passados como argumento
def follow_paths(paths)
  paths.each do |path|
    execute "le follow #{path}" do
      command "le follow #{path}"
      ignore_failure true
      action :run
    end
  end
end

general_paths = [ "/var/log/syslog", "/var/log/auth.log", "/var/log/daemon.log" ]

if ['app_master', 'app'].include?(node[:instance_role])
  app_paths = general_paths.dup

  (node[:applications] || []).each do |app_name, app_info|
    app_paths << "/var/log/nginx/#{app_name}.access.log"
    app_paths << "/var/log/engineyard/apps/#{app_name}/production.log"
    app_paths << "/var/log/nginx/#{app_name}.error.log"
  end

  follow_paths(app_paths)
end

if ['db_master', 'db_slave'].include?(node[:instance_role])
  db_paths = general_paths.dup
  db_paths << "/var/log/mysql/mysql.log"
  db_paths << "/var/log/mysql/mysql.err"

  follow_paths(db_paths)
end

if ['util'].include?(node[:instance_role]) && node[:name] == 'background'
  util_paths = general_paths.dup
  (node[:applications] || []).each do |app_name, app_info|
    util_paths << "/var/log/engineyard/apps/#{app_name}/delayed_job.log"
  end

  follow_paths(util_paths)
end
