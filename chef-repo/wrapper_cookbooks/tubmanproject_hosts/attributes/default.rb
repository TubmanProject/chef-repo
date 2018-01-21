# Cookbook Name:: tubmanproject_hosts
# Attribute:: default
#
# Copyright 2017, Tyrone Saunders. All Rights Reserved.


####################
# Data Bag Secrets #
####################
if Chef::Config[:solo]
  default['secrets']['mongodb'] = Chef::DataBagItem.load('secrets', 'mongodb')
  default['secrets']['rabbitmq'] = Chef::DataBagItem.load('secrets', 'rabbitmq')
  default['secrets']['redis'] = Chef::DataBagItem.load('secrets', 'redis')
else
  default['secrets']['mongodb'] = Chef::EncryptedDataBagItem.load('secrets', 'mongodb')
  default['secrets']['rabbitmq'] = Chef::EncryptedDataBagItem.load('secrets', 'rabbitmq')
  default['secrets']['redis'] = Chef::EncryptedDataBagItem.load('secrets', 'redis')
end

# when deploying multiple programs to an EC2 instance assume all programs have the same domain
apps = node['deploy']['app'][node.chef_environment]
jupyterhubs = node['deploy']['jupyterhub'][node.chef_environment]
redis_healthchecks = node['deploy']['redis-healthcheck'][node.chef_environment]
rabbitmq_healthchecks = node['deploy']['rabbitmq-healthcheck'][node.chef_environment]
mongodb_secret = node['secrets']['mongodb'][node.chef_environment]
redis_secret = node['secrets']['redis'][node.chef_environment]
rabbitmq_secret = node['secrets']['rabbitmq'][node.chef_environment]

# when deploying multiple programs to an EC2 instance assume all programs have the same domain
app = apps.first
default['hosts']['hostname'] = app['domain']

aliases = []

apps.each do |a|
  aliases.push("#{a['subdomain']}.#{a['domain']}")
  aliases.push(a['subdomain'])
end

jupyterhubs.each do |jh|
  aliases.push("#{jh['subdomain']}.#{jh['domain']}")
  aliases.push(jh['subdomain'])
end

redis_healthchecks.each do |rh|
  aliases.push("#{rh['subdomain']}.#{rh['domain']}")
  aliases.push(rh['subdomain'])
end

rabbitmq_healthchecks.each do |mqh|
  aliases.push("#{mqh['subdomain']}.#{mqh['domain']}")
  aliases.push(mqh['subdomain'])
end

aliases.push("#{mongodb_secret['hostname']}.#{mongodb_secret['domain']}")
aliases.push(mongodb_secret['hostname'])

# TODO: for disributed master-slave configuration only write the alias associated with the server
aliases.push("#{redis_secret['hostname']}.#{redis_secret['domain']}")
aliases.push(redis_secret['hostname'])
aliases.push("#{redis_secret['master']['name']}.#{redis_secret['domain']}")
aliases.push(redis_secret['master']['name'])
redis_secret['replicas'].each do |replica|
  aliases.push("#{replica['name']}.#{redis_secret['domain']}")
  aliases.push(replica['name'])
end

aliases.push("#{rabbitmq_secret['hostname']}.#{rabbitmq_secret['domain']}")
aliases.push(rabbitmq_secret['hostname'])
rabbitmq_secret['cluster_nodes'].each do |instance|
  aliases.push("#{instance['nodename']}.#{rabbitmq_secret['domain']}")
  aliases.push(instance['nodename'])
end

default['hosts']['aliases'] = aliases

default['hosts']['IPv4_loopback']['hostname'] = node['hosts']['hostname']
default['hosts']['IPv4_loopback']['aliases'] = node['hosts']['aliases'] + ['localhost']

default['hosts']['elastic_ip']['hostname'] = node['hosts']['hostname']
default['hosts']['elastic_ip']['aliases'] = node['hosts']['aliases']
