# Cookbook Name:: tubmanproject_haproxy
# Attribute:: default
#
# Copyright 2017, Tyrone Saunders. All Rights Reserved.

default['haproxy']['balance_algorithm'] = 'roundrobin'

####################
# HaProxy bindings #
####################
# RabbitMQ
default['haproxy']['rabbitmq']['host'] = '127.0.0.1'
default['haproxy']['rabbitmq']['port'] = 5772
default['haproxy']['rabbitmq']['settings']
# Redis
default['haproxy']['redis']['master']['host'] = '127.0.0.1'
default['haproxy']['redis']['master']['port'] = 6479
default['haproxy']['redis']['slave']['host'] = '127.0.0.1'
default['haproxy']['redis']['slave']['port'] = 6480
default['haproxy']['redis']['settings']

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

###############################
# user/owner for applications #
###############################
default['app']['user'] = "www-data"
