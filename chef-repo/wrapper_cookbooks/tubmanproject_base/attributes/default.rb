# Cookbook Name:: tubmanproject_base
# Attribute:: default
#
# Copyright 2017, Tyrone Saunders. All Rights Reserved.

#####################
# env specific vars #
#####################
if ["development"].include?(node.chef_environment)
  default['ssh']['user'] = 'vagrant'
elsif ["staging"].include?(node.chef_environment)
  default['ssh']['user'] = 'ubuntu'
else
  default['ssh']['user'] = 'ubuntu'
end

default['timezone'] = 'America/Chicago' # or use UTC, America/Chicago, America/Anchorage, America/Los_Angeles

###############################
# user/owner for applications #
###############################
default['app']['user'] = 'www-data'

#########################
# Environment variables #
#########################
default['environment']['variables'] = {}
default['environment']['variables']['APPLICATION_MODE'] = node.chef_environment.upcase
default['environment']['variables']['XDG_CONFIG_DIRS'] = '/etc/xdg/.config'
default['environment']['variables']['APP_SECRETS_PATH'] = '$XDG_CONFIG_DIRS'
default['environment']['variables']['MONGODB_SECRETS_PATH'] = '$XDG_CONFIG_DIRS/mongodb'
default['environment']['variables']['RABBITMQ_SECRETS_PATH'] = '$XDG_CONFIG_DIRS/rabbitmq'
default['environment']['variables']['REDIS_SECRETS_PATH'] = '$XDG_CONFIG_DIRS/redis'
default['environment']['variables']['MONGODB_HAPROXY_SECRETS_PATH'] = '$XDG_CONFIG_DIRS/haproxy/mongodb'
default['environment']['variables']['RABBITMQ_HAPROXY_SECRETS_PATH'] = '$XDG_CONFIG_DIRS/haproxy/rabbitmq'
default['environment']['variables']['REDIS_HAPROXY_SECRETS_PATH'] = '$XDG_CONFIG_DIRS/haproxy/redis'
default['environment']['variables']['AWS_SHARED_CREDENTIALS_FILE'] = "$XDG_CONFIG_DIRS/.aws/credentials"
default['environment']['variables']['TIMEZONE'] = node['timezone']

# literal
default['env']['vars'] = {}
default['env']['vars']['APPLICATION_MODE'] = node.chef_environment.upcase
default['env']['vars']['XDG_CONFIG_DIRS'] = '/etc/xdg/.config'
default['env']['vars']['APP_SECRETS_PATH'] = node['env']['vars']['XDG_CONFIG_DIRS']
default['env']['vars']['MONGODB_SECRETS_PATH'] = "#{node['env']['vars']['XDG_CONFIG_DIRS']}/mongodb"
default['env']['vars']['RABBITMQ_SECRETS_PATH'] = "#{node['env']['vars']['XDG_CONFIG_DIRS']}/rabbitmq"
default['env']['vars']['REDIS_SECRETS_PATH'] = "#{node['env']['vars']['XDG_CONFIG_DIRS']}/redis"
default['env']['vars']['MONGODB_HAPROXY_SECRETS_PATH'] = "#{node['env']['vars']['XDG_CONFIG_DIRS']}/haproxy/mongodb"
default['env']['vars']['RABBITMQ_HAPROXY_SECRETS_PATH'] = "#{node['env']['vars']['XDG_CONFIG_DIRS']}/haproxy/rabbitmq"
default['env']['vars']['REDIS_HAPROXY_SECRETS_PATH'] = "#{node['env']['vars']['XDG_CONFIG_DIRS']}/haproxy/redis"
default['env']['vars']['AWS_SHARED_CREDENTIALS_FILE'] = "#{node['env']['vars']['XDG_CONFIG_DIRS']}/.aws/credentials"
default['env']['vars']['TIMEZONE'] = node['timezone']

####################
# Data Bag Secrets #
####################
if Chef::Config[:solo]
  default['secrets']['aws'] = Chef::DataBagItem.load('secrets', 'aws')
  default['secrets']['github'] = Chef::DataBagItem.load('secrets', 'github')
  default['secrets']['data_bag'] = Chef::DataBagItem.load('secrets', 'data_bag')
  default['secrets']['host_machine'] = Chef::DataBagItem.load('secrets', 'host_machine')
  default['secrets']['jupyterhub_users'] = Chef::DataBagItem.load('secrets', 'jupyterhub_users')
  default['secrets']['oauth'] = Chef::DataBagItem.load('secrets', 'oauth')
  default['secrets']['openssl'] = Chef::DataBagItem.load('secrets', 'openssl')
  default['secrets']['ssh_keys'] = Chef::DataBagItem.load('secrets', 'ssh_keys')
  default['secrets']['mongodb'] = Chef::DataBagItem.load('secrets', 'mongodb')
  default['secrets']['rabbitmq'] = Chef::DataBagItem.load('secrets', 'rabbitmq')
  default['secrets']['redis'] = Chef::DataBagItem.load('secrets', 'redis')
else
  default['secrets']['aws'] = Chef::EncryptedDataBagItem.load('secrets', 'aws')
  default['secrets']['github'] = Chef::EncryptedDataBagItem.load('secrets', 'github')
  default['secrets']['data_bag'] = Chef::EncryptedDataBagItem.load('secrets', 'data_bag')
  default['secrets']['host_machine'] = Chef::EncryptedDataBagItem.load('secrets', 'host_machine')
  default['secrets']['jupyterhub_users'] = Chef::EncryptedDataBagItem.load('secrets', 'jupyterhub_users')
  default['secrets']['oauth'] = Chef::EncryptedDataBagItem.load('secrets', 'oauth')
  default['secrets']['openssl'] = Chef::EncryptedDataBagItem.load('secrets', 'openssl')
  default['secrets']['ssh_keys'] = Chef::EncryptedDataBagItem.load('secrets', 'ssh_keys')
  default['secrets']['mongodb'] = Chef::EncryptedDataBagItem.load('secrets', 'mongodb')
  default['secrets']['rabbitmq'] = Chef::EncryptedDataBagItem.load('secrets', 'rabbitmq')
  default['secrets']['redis'] = Chef::EncryptedDataBagItem.load('secrets', 'redis')
end
##########################
# Un-encrypted Data Bags #
##########################
default['deploy']['app'] = Chef::DataBagItem.load('deploy', 'app')
default['deploy']['jupyterhub'] = Chef::DataBagItem.load('deploy', 'jupyterhub')
default['deploy']['redis-healthcheck'] = Chef::DataBagItem.load('deploy', 'redis-healthcheck')
default['deploy']['rabbitmq-healthcheck'] = Chef::DataBagItem.load('deploy', 'rabbitmq-healthcheck')

# Other attributes
node.override['sysctl']['conf_file'] = '/etc/sysctl.conf'
