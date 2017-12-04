#
# Cookbook:: tubmanproject_docker
# Recipe:: install
#
# Copyright:: 2017, Tyrone Saunders, All Rights Reserved.

# official docker repository
include_recipe 'chef-apt-docker'

# install and start docker with a service
docker_service "default" do
  action [:create, :start]
end

# create a configuration directory
directory '/etc/docker' do
  recursive true
  mode '0755'
  not_if {::Dir.exist?('/etc/docker')}
end
