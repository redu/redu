#
# Cookbook Name:: le
# Recipe:: install
#

directory "/engineyard/portage/engineyard/dev-util/le" do
  owner "root"
  group "root"
  mode "0755"
  recursive true
  action :create
end

remote_file "/engineyard/portage/engineyard/dev-util/le/le-0.0.0.ebuild" do
  source "https://rep.logentries.com/gentoo/le.ebuild"
  mode "0644"
end

execute "ebuild le-0.0.0.ebuild digest" do
  command "ebuild le-0.0.0.ebuild digest"
  cwd "/engineyard/portage/engineyard/dev-util/le/"
  # only_if { `eix dev-util/le -O` =~ /No matches found./ }
end

package 'dev-util/le' do
  version node['0.0.0']
  action :install
end

# ln -s /usr/bin/le /usr/bin/le-monitordaemon
link "/usr/bin/le-monitordaemon" do
	to "/usr/bin/le"
end

# init.d script for le agent
template '/etc/init.d/logentries' do
	source 'logentries.initd.erb'
	mode '0755'
end

# Start agent when instance boots
execute 'start logentries at boot' do
	command %{rc-update add logentries default}
	creates '/etc/runlevels/default/logentries'
end
