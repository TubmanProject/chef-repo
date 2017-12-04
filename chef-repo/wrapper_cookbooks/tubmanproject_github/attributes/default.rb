# Cookbook Name:: tubmanproject_github
# Attribute:: default
#
# Copyright 2017, Tyrone Saunders. All Rights Reserved.

####################
# Data Bag Secrets #
####################
if Chef::Config[:solo]
  default['secrets']['github'] = Chef::DataBagItem.load('secrets', 'github')
else
  default['secrets']['github'] = Chef::EncryptedDataBagItem.load('secrets', 'github')
end

#####################
# env specific vars #
#####################
if ["development"].include?(node.chef_environment)
  default['ssh']['user'] = 'vagrant'
elsif ["staging"].include?(node.chef_environment)
  default['ssh']['user'] = 'ubuntu'  
else
  default['ssh']['user'] = 'ubuntu'
end