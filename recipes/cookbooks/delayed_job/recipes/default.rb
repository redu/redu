#
# Cookbook Name:: delayed_job
# Recipe:: default
#

if node[:instance_role] == 'util'
  app_name = 'redu'
  %w(general email vis).each_with_index do |queue, count|
    template "/etc/monit.d/delayed_job.#{count}.#{app_name}.monitrc" do
      source "dj.monitrc.erb"
      owner "root"
      group "root"
      mode 0644
      variables({
        :app_name => app_name,
        :queue => queue,
        :user => node[:owner_name],
        :worker_name => "delayed_job.#{count}",
        :pid_name => "delayed_job.#{count}.pid",
        :count => count,
        :framework_env => node[:environment][:framework_env],
      })
    end
  end

  execute "monit reload" do
    action :run
    epic_fail true
  end
end
