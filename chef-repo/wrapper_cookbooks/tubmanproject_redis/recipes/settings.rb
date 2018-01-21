#
# Cookbook:: tubmanproject_redis
# Recipe:: settings
#
# Copyright:: 2017, Tyrone Saunders, All Rights Reserved.

redis_settings = {}
redis_settings['SSL'] = {}
redis_settings['MASTER'] = {}
redis_settings['SLAVES'] = []

master = node['secrets']['redis'][node.chef_environment]['master']
replicas = node['secrets']['redis'][node.chef_environment]['replicas']

# REDIS_HOST = 'localhost'
redis_settings['MASTER']['HOST'] = node['ipaddress']
# REDIS_PORT = 6379
redis_settings['MASTER']['PORT'] = master['port']
# REDIS_PASSWORD = None
redis_settings['MASTER']['PASSWORD'] = master['password']

replicas.each do |replica|
  slave_config = {}
  slave_config['HOST'] = node['ipaddress']
  slave_config['PORT'] = replica['port']
  slave_config['MASTERAUTH'] = replica['masterauth']
  redis_settings['SLAVES'].push(slave_config)
end

redis_settings['SSL']['KEYFILE'] = "#{node['redisio']['directories']['ssl']}/#{node['redisio']['keyfile_name']}"
redis_settings['SSL']['CERTFILE'] = "#{node['redisio']['directories']['ssl']}/#{node['redisio']['certfile_name']}"

node.override['redisio']['settings'] = redis_settings

####################################
# create configuration directories #
####################################
group 'config-secrets' do
  action :modify
  append true
  members [node['ssh']['user'], node['app']['user']]
end

directory '/etc/xdg/.config/redis' do
  recursive true
  owner node['ssh']['user']
  group 'config-secrets'
  mode '0750'
end

#######################
# write a config file #
#######################
file '/etc/xdg/.config/redis/secrets.json' do
  content lazy {Chef::JSONCompat.to_json_pretty(node['redisio']['settings'])}
  owner node['ssh']['user']
  group 'config-secrets'
  mode '0550'
end
