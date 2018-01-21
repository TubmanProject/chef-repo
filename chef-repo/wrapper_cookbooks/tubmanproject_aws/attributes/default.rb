# Cookbook Name:: tubmanproject_aws
# Attribute:: default
#
# Copyright 2017, Tyrone Saunders. All Rights Reserved.

default['chef_client']['version'] = '12.21.31'

####################
# Data Bag Secrets #
####################
if Chef::Config[:solo]
  default['secrets']['aws'] = Chef::DataBagItem.load('secrets', 'aws')
  default['secrets']['data_bag'] = Chef::DataBagItem.load('secrets', 'data_bag')
  default['secrets']['host_machine'] = Chef::DataBagItem.load('secrets', 'host_machine')
else
  default['secrets']['aws'] = Chef::EncryptedDataBagItem.load('secrets', 'aws')
  default['secrets']['data_bag'] = Chef::EncryptedDataBagItem.load('secrets', 'data_bag')
  default['secrets']['host_machine'] = Chef::EncryptedDataBagItem.load('secrets', 'host_machine')
end
##########################
# Un-encrypted Data Bags #
##########################
default['deploy']['app'] = Chef::DataBagItem.load('deploy', 'app')
default['deploy']['jupyterhub'] = Chef::DataBagItem.load('deploy', 'jupyterhub')
