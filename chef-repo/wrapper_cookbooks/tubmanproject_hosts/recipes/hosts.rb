#
# Cookbook:: tubmanproject_hosts
# Recipe:: hosts
#
# Copyright:: 2017, Tyrone Saunders, All Rights Reserved.

hostsfile_entry '127.0.0.1' do
  hostname  node['hosts']['IPv4_loopback']['hostname']
  aliases node['hosts']['IPv4_loopback']['aliases']
  action :append
end

# for AWS provisioning the node['aws']['elastic_ip'] is set on the machine resource
if node.attribute?('aws')
  if node['aws'].attribute?('elastic_ip')
    hostsfile_entry node['aws']['elastic_ip'] do
      hostname  node['hosts']['elastic_ip']['hostname']
      aliases node['hosts']['elastic_ip']['aliases']
      action :append
    end 
  end
end
