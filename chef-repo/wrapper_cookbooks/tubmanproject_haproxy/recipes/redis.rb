#
# Cookbook:: tubmanproject_haproxy
# Recipe:: redis
#
# Copyright:: 2017, Tyrone Saunders, All Rights Reserved.

master = node['secrets']['redis'][node.chef_environment]['master']
replicas = node['secrets']['redis'][node.chef_environment]['replicas']

################
# Redis Master #
################
haproxy_frontend 'redis_master_in' do
  bind "#{node['haproxy']['redis']['master']['host']}:#{node['haproxy']['redis']['master']['port']}"
  mode 'tcp'
  default_backend 'redis_master_servers'
end

redis_master_servers = ["#{master['name']}-#{master['port']} #{node['ipaddress']}:#{master['port']}"]

haproxy_backend 'redis_master_servers' do
  mode 'tcp'
  server redis_master_servers
  extra_options(
    balance: 'roundrobin'
  )
end

################
# Redis Slaves #
################
haproxy_frontend 'redis_slave_in' do
  bind "#{node['haproxy']['redis']['slave']['host']}:#{node['haproxy']['redis']['slave']['port']}"
  mode 'tcp'
  default_backend 'redis_slave_servers'
end

redis_slave_servers = []
replicas.each do |slave|
  redis_slave_servers.push("#{slave['name']}-#{slave['port']} #{node['ipaddress']}:#{slave['port']}")
end

haproxy_backend 'redis_slave_servers' do
  mode 'tcp'
  server redis_slave_servers
  extra_options(
    balance: 'roundrobin'
  )
end

############################
# set configuration values #
############################
json_config = {}
json_config['REDIS_HAPROXY'] = {}
json_config['REDIS_HAPROXY']['MASTER'] = {}
json_config['REDIS_HAPROXY']['SLAVE'] = {}
json_config['REDIS_HAPROXY']['MASTER']['PASSWORD'] = master['password']
json_config['REDIS_HAPROXY']['MASTER']['HOST'] = node['haproxy']['redis']['master']['host']
json_config['REDIS_HAPROXY']['MASTER']['PORT'] = node['haproxy']['redis']['master']['port']
json_config['REDIS_HAPROXY']['SLAVE']['HOST'] = node['haproxy']['redis']['slave']['host']
json_config['REDIS_HAPROXY']['SLAVE']['PORT'] = node['haproxy']['redis']['slave']['port']

node.override['haproxy']['redis']['settings'] = json_config
####################################
# create configuration directories #
####################################
group 'config-secrets' do
  action :modify
  append true
  members [node['ssh']['user'], node['app']['user']]
end

directory '/etc/xdg/.config/haproxy/redis' do
  recursive true
  owner node['ssh']['user']
  group 'config-secrets'
  mode '0750'
end

#######################
# write a config file #
#######################
file '/etc/xdg/.config/haproxy/redis/secrets.json' do
  content lazy {Chef::JSONCompat.to_json_pretty(node['haproxy']['redis']['settings'])}
  owner node['ssh']['user']
  group 'config-secrets'
  mode '0550'
end
