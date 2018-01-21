#
# Cookbook:: tubmanproject_mongodb
# Recipe:: settings
#
# Copyright:: 2017, Tyrone Saunders, All Rights Reserved.

mongodb = node['secrets']['mongodb'][node.chef_environment]

mongodb_settings = {}

mongodb_settings['HOST'] = "#{mongodb['hostname']}.#{mongodb['domain']}"
mongodb_settings['HOSTNAME'] = mongodb['hostname']
mongodb_settings['PORT'] = mongodb['port']
mongodb_settings['USERS'] = mongodb['users']
mongodb_settings['PEMKeyFile'] = "#{node['mongodb']['directories']['ssl']}/#{node['mongodb']['pem_keyfile_name']}"

node.override['mongodb']['settings'] = mongodb_settings

####################################
# create configuration directories #
####################################
group 'config-secrets' do
  action :modify
  append true
  members [node['ssh']['user'], node['app']['user']]
end

directory "/etc/xdg/.config/mongodb" do
  recursive true
  owner node['ssh']['user']
  group 'config-secrets'
  mode '0750'
end

#######################
# write a config file #
#######################
file "/etc/xdg/.config/mongodb/secrets.json" do
  content lazy {Chef::JSONCompat.to_json_pretty(node['mongodb']['settings'])}
  owner node['ssh']['user']
  group 'config-secrets'
  mode '0550'
end
