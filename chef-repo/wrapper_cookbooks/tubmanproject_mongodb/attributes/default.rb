# Cookbook Name:: tubmanproject_mongodb
# Attribute:: default
#
# Copyright 2017, Tyrone Saunders. All Rights Reserved.

####################
# Data Bag Secrets #
####################
if Chef::Config[:solo] 
  default['secrets']['mongodb'] = Chef::DataBagItem.load('secrets', 'mongodb')    
else
  default['secrets']['mongodb'] = Chef::EncryptedDataBagItem.load('secrets', 'mongodb') 
end

node.override['mongodb']['package_version'] = '3.4.10'
node.override['mongodb']['config']['mongod']['net']['bindIp'] = '127.0.0.1'
node.override['mongodb']['config']['mongos']['net']['bindIp'] = '127.0.0.1'

# enable authentication
node.override['mongodb']['config']['auth'] = true

# overwrite default values
node.override['mongodb']['authentication']['username'] = node['secrets']['mongodb'][node.chef_environment]['admin']['username']
node.override['mongodb']['authentication']['password'] = node['secrets']['mongodb'][node.chef_environment]['admin']['password']

node.override['mongodb']['admin'] = {
  'username' => default['mongodb']['authentication']['username'],
  'password' => default['mongodb']['authentication']['password'],
  'roles' => node['secrets']['mongodb'][node.chef_environment]['admin']['roles'],
  'database' => node['secrets']['mongodb'][node.chef_environment]['admin']['database'],
}

node.override['mongodb']['mongos_create_admin'] = true

default['mongodb']['directories']['runtime'] = '/srv/mongodb'
default['mongodb']['directories']['configuration'] = '/etc/mongodb'
default['mongodb']['directories']['ssl'] = "#{node['mongodb']['directories']['runtime']}/ssl"
default['mongodb']['pem_keyfile_name'] = 'mongodb.pem'

# ssl configuration
node.override['mongodb']['config']['mongod']['net']['ssl'] = {
  'mode' => 'requireSSL',
  'PEMKeyFile' => "#{node['mongodb']['directories']['ssl']}/#{node['mongodb']['pem_keyfile_name']}"
}

node.override['mongods']['config']['mongod']['net']['ssl'] = {
  'mode' => 'requireSSL',
  'PEMKeyFile' => "#{node['mongodb']['directories']['ssl']}/#{node['mongodb']['pem_keyfile_name']}"
}