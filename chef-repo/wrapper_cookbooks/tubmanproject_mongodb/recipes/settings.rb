#
# Cookbook:: tubmanproject_mongodb
# Recipe:: settings
#
# Copyright:: 2017, Tyrone Saunders, All Rights Reserved.

###############################
# user/owner for applications #
###############################
default['app']['user'] = "www-data"

Chef::Recipe.send(:include, OpenSSLCookbook::RandomPassword)

mongodb = node['secrets']['mongodb'][node.chef_environment]

mongdb_settings = {}

mongodb_settings['HOST'] = "#{mongodb['hostname']}.#{mongodb['domain']}"
mongodb_settings['HOSTNAME'] = mongodb['hostname']
mongodb_settings['USERS'] = mongodb['users']
mongodb_settings['PEMKeyFile'] = "#{node['mongodb']['directories']['ssl']}/#{node['mongodb']['pem_keyfile_name']}"


node.override['mongodb']['settings'] = mongodb_settings

####################################
# create configuration directories #
####################################
directory "/etc/xdg/.config/mongodb" do
  recursive true
  owner node['app']['user']
  group 'mongodb'
  mode "0770"
end

#######################
# write a config file #
#######################
file "/etc/xdg/.config/mongodb/secrets.json" do
  content lazy {Chef::JSONCompat.to_json_pretty(node['mongodb']['settings'])}
  owner node['app']['user']
  group 'mongodb'
  mode 0660
end