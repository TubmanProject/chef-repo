#
# Cookbook:: tubmanproject_haproxy
# Recipe:: rabbitmq
#
# Copyright:: 2017, Tyrone Saunders, All Rights Reserved.

rabbitmq_clusters = node['secrets']['rabbitmq'][node.chef_environment]['cluster_nodes']

haproxy_frontend 'rabbitmq_in' do
  bind "#{node['haproxy']['rabbitmq']['host']}:#{node['haproxy']['rabbitmq']['port']}"
  mode 'tcp'
  option ['clitcpka']
  default_backend 'rabbitmq_servers'
  extra_options(
    'timeout client' => "#{3 * 60 * 60}s"
  )
end

rabbitmq_servers = []
rabbitmq_clusters.each do |rabbitmq_node|
  rabbitmq_servers.push("#{rabbitmq_node['nodename']} #{node['ipaddress']}:#{rabbitmq_node['port']} check inter 5s rise 2 fall 3")
end

haproxy_backend 'rabbitmq_servers' do
  mode 'tcp'
  server rabbitmq_servers
  extra_options(
    balance: 'roundrobin',
    'timeout server' => "#{3 * 60 * 60}s"
  )
end

############################
# set configuration values #
############################
json_config = {}
json_config['RABBITMQ_HAPROXY'] = {}
json_config['RABBITMQ_HAPROXY']['HOST'] = node['haproxy']['rabbitmq']['host']
json_config['RABBITMQ_HAPROXY']['PORT'] = node['haproxy']['rabbitmq']['port']

node.override['haproxy']['rabbitmq']['settings'] = json_config
####################################
# create configuration directories #
####################################
group 'config-secrets' do
  action :modify
  append true
  members [node['ssh']['user'], node['app']['user']]
end

directory '/etc/xdg/.config/haproxy/rabbitmq' do
  recursive true
  owner node['ssh']['user']
  group 'config-secrets'
  mode '0750'
end

#######################
# write a config file #
#######################
file '/etc/xdg/.config/haproxy/rabbitmq/secrets.json' do
  content lazy {Chef::JSONCompat.to_json_pretty(node['haproxy']['rabbitmq']['settings'])}
  owner node['ssh']['user']
  group 'config-secrets'
  mode '0550'
end
