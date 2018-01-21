#
# Cookbook:: tubmanproject_redis
# Recipe:: master
#
# Copyright:: 2017, Tyrone Saunders, All Rights Reserved.

# data bag configuration
master = node['secrets']['redis'][node.chef_environment]['master']

########################
# master configuration #
########################

config_settings = {}
config_settings['port'] = master['port']
config_settings['name'] = "#{master['name']}.#{node['secrets']['redis'][node.chef_environment]['domain']}"
config_settings['requirepass'] = master['password']
config_settings['keepalive'] = 60
config_settings['backuptype'] = 'both'
config_settings['logfile'] = "/var/log/redis/#{master['name']}.#{node['secrets']['redis'][node.chef_environment]['domain']}.log"
config_settings['syslogenabled'] = 'no'

node.override['redisio']['servers'][config_settings['name']] = config_settings
node.override['redisio']['master']['servers'][config_settings['name']] = config_settings
node.override['redisio']['master']['server']['current'] = config_settings

node.override['redisio']['master']['ip']['public'] = node['ipaddress']
node.override['redisio']['master']['ip']['private'] = node['ipaddress']
