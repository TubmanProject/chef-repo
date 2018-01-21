#
# Cookbook:: mintyross_redis
# Recipe:: slave
#
# Copyright:: 2017, Tyrone Saunders, All Rights Reserved.

Chef::Recipe.send(:include, OpenSSLCookbook::RandomPassword)

# data bag configuration
master = node['secrets']['redis'][node.chef_environment]['master']
replicas = node['secrets']['redis'][node.chef_environment]['replicas']

#########################
# replica configuration #
#########################
# secure read-only redis slave instance by obfusticating admin commands
rename_commands = {}
rename_commands['CONFIG'] = random_password(length: 8)
rename_commands['DEBUG'] = random_password(length: 8)
rename_commands['FLUSHDB'] = random_password(length: 8)
rename_commands['FLUSHALL'] = random_password(length: 8)
rename_commands['SHUTDOWN'] = random_password(length: 8)

# Configure each Redis slave
replicas.each do |replica|
  config_settings = {}
  config_settings['rename_commands'] = rename_commands
  config_settings['port'] = replica['port']
  config_settings['name'] = "#{replica['name']}.#{node['secrets']['redis'][node.chef_environment]['domain']}"
  config_settings['masterauth'] = replica['master_auth']
  config_settings['keepalive'] = 60
  config_settings['backuptype'] = 'both'
  config_settings['logfile'] = "/var/log/redis/#{replica['name']}.#{node['secrets']['redis'][node.chef_environment]['domain']}.log"
  config_settings['syslogenabled'] = 'no'
  config_settings['slaveof'] = {}
  config_settings['slaveof']['address'] = node['redisio']['master']['ip']['public']
  config_settings['slaveof']['port'] = master['port']

  node.override['redisio']['servers'][config_settings['name']] = config_settings
  node.override['redisio']['slave']['servers'][config_settings['name']] = config_settings
  node.override['redisio']['slave']['server']['current'] = config_settings

  node.override['redisio']['slave']['ip']['public'] = node['ipaddress']
  node.override['redisio']['slave']['ip']['private'] = node['ipaddress']
end
