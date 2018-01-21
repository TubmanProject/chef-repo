# Cookbook Name:: tubmanproject_redis
# Attribute:: default
#
# Copyright 2017, Tyrone Saunders. All Rights Reserved.

####################
# Data Bag Secrets #
####################
if Chef::Config[:solo]
  default['secrets']['aws'] = Chef::DataBagItem.load('secrets', 'aws')
  default['secrets']['data_bag'] = Chef::DataBagItem.load('secrets', 'data_bag')
  default['secrets']['github'] = Chef::DataBagItem.load('secrets', 'github')
  default['secrets']['host_machine'] = Chef::DataBagItem.load('secrets', 'host_machine')
  default['secrets']['openssl'] = Chef::DataBagItem.load('secrets', 'openssl')
  default['secrets']['redis'] = Chef::DataBagItem.load('secrets', 'redis')
else
  default['secrets']['aws'] = Chef::EncryptedDataBagItem.load('secrets', 'aws')
  default['secrets']['data_bag'] = Chef::EncryptedDataBagItem.load('secrets', 'data_bag')
  default['secrets']['github'] = Chef::EncryptedDataBagItem.load('secrets', 'github')
  default['secrets']['host_machine'] = Chef::EncryptedDataBagItem.load('secrets', 'host_machine')
  default['secrets']['openssl'] = Chef::EncryptedDataBagItem.load('secrets', 'openssl')
  default['secrets']['redis'] = Chef::EncryptedDataBagItem.load('secrets', 'redis')
end
default['deploy']['redis-healthcheck'] = Chef::DataBagItem.load('deploy', 'redis-healthcheck')

###############
# Directories #
###############
default['redisio']['directories']['runtime'] = '/srv/redisio'
default['redisio']['directories']['configuration'] = '/etc/redisio'
default['redisio']['directories']['ssl'] = "#{node['redisio']['directories']['runtime']}/ssl"
default['redisio']['certfile_name'] = 'redisio.pem'
default['redisio']['keyfile_name'] = 'redisio.key'

####################
# Redis attributes #
####################
node.override['redisio']['version'] = '4.0.6'
node.override['redisio']['bypass_setup'] = true
##########################
# Redis local attributes #
##########################
default['redisio']['servers']
default['redisio']['settings']

###########################
# Redis master attributes #
###########################
default['redisio']['master']['ip']['public'] = ''
default['redisio']['master']['ip']['private'] = ''
default['redisio']['master']['servers']
default['redisio']['master']['server']['current']

############################
# Redis replica attributes #
############################
default['redisio']['slave']['ip']['public'] = ''
default['redisio']['slave']['ip']['private'] = ''
default['redisio']['slave']['servers']
default['redisio']['slave']['server']['current']

default['service']['redis'] = 'redis'

###############################
# user/owner for applications #
###############################
default['app']['user'] = 'www-data'
