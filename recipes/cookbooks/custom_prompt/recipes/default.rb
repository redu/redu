template "/home/#{node[:owner_name]}/.bash_profile" do
  owner node[:owner_name]
  group node[:owner_name]
  mode 0644
  source "bash_profile.erb"
  variables({
    :role => node[:instance_role],
    :instance_id => node[:engineyard][:this],
    :environment => node[:engineyard][:environment][:name]
  })
end
