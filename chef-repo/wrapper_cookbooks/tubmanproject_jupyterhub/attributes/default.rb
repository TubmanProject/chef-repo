# Cookbook Name:: tubmanproject_jupyterhub
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
  default['secrets']['jupyterhub_users'] = Chef::DataBagItem.load('secrets', 'jupyterhub_users')
  default['secrets']['oauth'] = Chef::DataBagItem.load('secrets', 'oauth')
else
  default['secrets']['aws'] = Chef::EncryptedDataBagItem.load('secrets', 'aws')
  default['secrets']['github'] = Chef::EncryptedDataBagItem.load('secrets', 'github')
  default['secrets']['ssh_keys'] = Chef::EncryptedDataBagItem.load('secrets', 'ssh_keys')
  default['secrets']['data_bag'] = Chef::EncryptedDataBagItem.load('secrets', 'data_bag')
  default['secrets']['host_machine'] = Chef::EncryptedDataBagItem.load('secrets', 'host_machine')
  default['secrets']['openssl'] = Chef::EncryptedDataBagItem.load('secrets', 'openssl')
  default['secrets']['jupyterhub_users'] = Chef::EncryptedDataBagItem.load('secrets', 'jupyterhub_users')
  default['secrets']['oauth'] = Chef::EncryptedDataBagItem.load('secrets', 'oauth')
end

##########################
# Un-encrypted Data Bags #
##########################
default['deploy']['jupyterhub'] = Chef::DataBagItem.load('deploy', 'jupyterhub')

default['jupyterhub']['user'] = 'root'
default['jupyterhub']['admin_access'] = false
default['jupyterhub']['create_system_users'] = true
default['jupyterhub']['disable_user_config'] = true
default['jupyterhub']['directories']['runtime'] = '/srv/jupyterhub'
default['jupyterhub']['directories']['configuration'] = '/etc/jupyterhub'
default['jupyterhub']['directories']['ssl'] = "#{node['jupyterhub']['directories']['runtime']}/ssl"
default['jupyterhub']['directories']['log'] = '/var/log/jupyterhub'

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
