# Cookbook Name:: tubmanproject_hosts
# Attribute:: default
#
# Copyright 2017, Tyrone Saunders. All Rights Reserved.

# when deploying multiple programs to an EC2 instance assume all programs have the same domain
apps = node['deploy']['app'][node.chef_environment]
jupyterhubs = node['deploy']['jupyterhub'][node.chef_environment]

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


default['hosts']['aliases'] = aliases

default['hosts']['IPv4_loopback']['hostname'] = node['hosts']['hostname']
default['hosts']['IPv4_loopback']['aliases'] = node['hosts']['aliases'] + ['localhost']

default['hosts']['elastic_ip']['hostname'] = node['hosts']['hostname']
default['hosts']['elastic_ip']['aliases'] = node['hosts']['aliases']