#
# Cookbook:: tubmanproject_rabbitmq
# Recipe:: settings
#
# Copyright:: 2017, Tyrone Saunders, All Rights Reserved.

rabbitmq_settings = {}
rabbitmq_settings['SSL'] = {}

####################
# Data Bag Secrets #
####################
apps = node['secrets']['rabbitmq'][node.chef_environment]['applications']
rabbitmq_clusters = node['secrets']['rabbitmq'][node.chef_environment]['cluster_nodes']

# initialize rabbitmq object
apps.each do |app|
  rabbitmq_settings[app['vhost']] = {}
  rabbitmq_settings[app['vhost']]['broker_urls'] = []
end

rabbitmq_clusters.each do |rabbitmq_node|
  # writing settings to local server use node['ipaddress'] because,
  # "At the beginning of a chef-client run, all attributes are reset."
  # for local servers only use port 5672 in the app
  apps.each do |app|
    rabbitmq_settings[app['vhost']]['broker_urls'].push("amqp://#{app['users'].first['username']}:#{app['users'].first['password']}@#{node['ipaddress']}:#{rabbitmq_node['port']}")
    rabbitmq_settings[app['vhost']]['username'] = app['users'].first['username']
    rabbitmq_settings[app['vhost']]['password'] = app['users'].first['password']
  end
end

rabbitmq_settings['SSL']['KEYFILE'] = "#{node['rabbitmq']['directories']['ssl']}/#{node['rabbitmq']['keyfile_name']}"
rabbitmq_settings['SSL']['CERTFILE'] = "#{node['rabbitmq']['directories']['ssl']}/#{node['rabbitmq']['certfile_name']}"

node.override['rabbitmq']['settings'] = rabbitmq_settings

####################################
# create configuration directories #
####################################
group 'config-secrets' do
  action :modify
  append true
  members [node['ssh']['user'], node['app']['user']]
end

directory '/etc/xdg/.config/rabbitmq' do
  recursive true
  owner node['ssh']['user']
  group 'config-secrets'
  mode '0750'
end

#######################
# write a config file #
#######################
file '/etc/xdg/.config/rabbitmq/secrets.json' do
  content lazy {Chef::JSONCompat.to_json_pretty(node['rabbitmq']['settings'])}
  owner node['ssh']['user']
  group 'config-secrets'
  mode '0550'
end
