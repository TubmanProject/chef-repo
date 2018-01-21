# Cookbook Name:: tubmanproject_app
# Attribute:: default
#
# Copyright 2017, Tyrone Saunders. All Rights Reserved.

####################
# Data Bag Secrets #
####################
if Chef::Config[:solo]
  default['secrets']['aws'] = Chef::DataBagItem.load('secrets', 'aws')
  default['secrets']['github'] = Chef::DataBagItem.load('secrets', 'github')
  default['secrets']['ssh_keys'] = Chef::DataBagItem.load('secrets', 'ssh_keys')
  default['secrets']['data_bag'] = Chef::DataBagItem.load('secrets', 'data_bag')
  default['secrets']['host_machine'] = Chef::DataBagItem.load('secrets', 'host_machine')
  default['secrets']['openssl'] = Chef::DataBagItem.load('secrets', 'openssl')
else
  default['secrets']['aws'] = Chef::EncryptedDataBagItem.load('secrets', 'aws')
  default['secrets']['github'] = Chef::EncryptedDataBagItem.load('secrets', 'github')
  default['secrets']['ssh_keys'] = Chef::EncryptedDataBagItem.load('secrets', 'ssh_keys')
  default['secrets']['data_bag'] = Chef::EncryptedDataBagItem.load('secrets', 'data_bag')
  default['secrets']['host_machine'] = Chef::EncryptedDataBagItem.load('secrets', 'host_machine')
  default['secrets']['openssl'] = Chef::EncryptedDataBagItem.load('secrets', 'openssl')
end

##########################
# Un-encrypted Data Bags #
##########################
default['deploy']['app'] = Chef::DataBagItem.load('deploy', 'app')
default['deploy']['jupyterhub'] = Chef::DataBagItem.load('deploy', 'jupyterhub')

default['app']['settings']
default['uwsgi']['reload']['file'] = 'reload-file'
default['uwsgi']['reload']['port'] = 9025
default['host_machine']['project_path'] = node['secrets']['host_machine']['project_path']
default['service']['app'] = 'app'

default['app']['directories']['runtime'] = '/srv/app'
default['app']['directories']['configuration'] = '/etc/app'
default['app']['directories']['ssl'] = "#{node['app']['directories']['runtime']}/ssl"
default['app']['directories']['log'] = '/var/log/app'

###############################
# user/owner for applications #
###############################
default['app']['user'] = 'www-data'

############################
# ACME certificate contact #
############################
unless ['development'].include?(node.chef_environment)
  node.override['acme']['contact'] = ["mailto:#{node['secrets']['openssl']['distinguished_name']['email']}"]
  if ['staging'].include?(node.chef_environment)
    node.override['acme']['endpoint'] = 'https://acme-staging.api.letsencrypt.org'
  end
  if ['production'].include?(node.chef_environment)
    node.override['acme']['endpoint'] = 'https://acme-v01.api.letsencrypt.org'
  end
end
