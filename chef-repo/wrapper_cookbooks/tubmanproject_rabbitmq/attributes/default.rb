# Cookbook Name:: tubmanproject_rabbitmq
# Attribute:: default
#
# Copyright 2017, Tyrone Saunders. All Rights Reserved.

####################
# Data Bag Secrets #
####################
if Chef::Config[:solo]
  default['secrets']['aws'] = Chef::DataBagItem.load('secrets', 'aws')
  default['secrets']['data_bag'] = Chef::DataBagItem.load('secrets', 'data_bag')
  default['secrets']['github'] = Chef::DataBagItem.load('secrets', 'github')
  default['secrets']['host_machine'] = Chef::DataBagItem.load('secrets', 'host_machine')
  default['secrets']['openssl'] = Chef::DataBagItem.load('secrets', 'openssl')
  default['secrets']['rabbitmq'] = Chef::DataBagItem.load('secrets', 'rabbitmq')
else
  default['secrets']['aws'] = Chef::EncryptedDataBagItem.load('secrets', 'aws')
  default['secrets']['data_bag'] = Chef::EncryptedDataBagItem.load('secrets', 'data_bag')
  default['secrets']['github'] = Chef::EncryptedDataBagItem.load('secrets', 'github')
  default['secrets']['host_machine'] = Chef::EncryptedDataBagItem.load('secrets', 'host_machine')
  default['secrets']['openssl'] = Chef::EncryptedDataBagItem.load('secrets', 'openssl')
  default['secrets']['rabbitmq'] = Chef::EncryptedDataBagItem.load('secrets', 'rabbitmq')
end

default['deploy']['rabbitmq-healthcheck'] = Chef::DataBagItem.load('deploy', 'rabbitmq-healthcheck')

###########
# Version #
###########
# disable upstart for Ubuntu 16.04 SystemD installs
node.override['rabbitmq']['manage_service'] = false
# use version > 3.6.3 in order to take advantage of systemd in debian installs
node.override['rabbitmq']['version'] = '3.6.14'
node.override['rabbitmq']['deb_package'] = "rabbitmq-server_#{node['rabbitmq']['version']}-1_all.deb"
node.override['rabbitmq']['deb_package_url'] = "https://www.rabbitmq.com/releases/rabbitmq-server/v#{node['rabbitmq']['version']}/"
node.override['rabbitmq']['rpm_package'] = "rabbitmq-server-#{node['rabbitmq']['version']}-1.noarch.rpm"
node.override['rabbitmq']['rpm_package_url'] = "https://www.rabbitmq.com/releases/rabbitmq-server/v#{node['rabbitmq']['version']}/"

#########################
# Environment Variables #
#########################
# set additional env settings as string "KEY=value", see https://www.rabbitmq.com/configure.html
default['rabbitmq']['additional_env_settings'] = []

###############
# Directories #
###############
default['rabbitmq']['directories']['runtime'] = '/srv/rabbitmq'
default['rabbitmq']['directories']['configuration'] = '/etc/rabbitmq'
default['rabbitmq']['directories']['ssl'] = "#{node['rabbitmq']['directories']['runtime']}/ssl"
default['rabbitmq']['certfile_name'] = 'rabbitmq.pem'
default['rabbitmq']['keyfile_name'] = 'rabbitmq.key'

######################
# Configuration File #
######################
node.override['rabbitmq']['logdir'] = '/var/log/rabbitmq' # directory created in default recipe
node.override['rabbitmq']['disk_free_limit_relative'] = 0.5
node.override['rabbitmq']['vm_memory_high_watermark'] = 0.65
node.override['rabbitmq']['max_file_descriptors'] = 65536
node.override['rabbitmq']['open_file_limit'] = 65536

#######
# SSL #
#######
node.override['rabbitmq']['ssl'] = false
node.override['rabbitmq']['ssl_port'] = 5671
# node.override['rabbitmq']['ssl_cacert'] = '/path/to/cacert.pem'
node.override['rabbitmq']['ssl_cert'] = "#{node['rabbitmq']['directories']['ssl']}/#{node['rabbitmq']['certfile_name']}"
node.override['rabbitmq']['ssl_key'] = "#{node['rabbitmq']['directories']['ssl']}/#{node['rabbitmq']['keyfile_name']}"
node.override['rabbitmq']['ssl_verify'] = 'verify_none'
node.override['rabbitmq']['ssl_fail_if_no_peer_cert'] = false
node.override['rabbitmq']['ssl_versions'] = nil

##############
# Clustering #
##############
default['rabbitmq']['clustering']['current']['nodename'] = ''
node.override['rabbitmq']['clustering']['use_auto_clustering'] = true
node.override['rabbitmq']['clustering']['cluster_name'] = node['secrets']['rabbitmq'][node.chef_environment]['cluster_name']

###############################
# user/owner for applications #
###############################
default['app']['user'] = "www-data"
