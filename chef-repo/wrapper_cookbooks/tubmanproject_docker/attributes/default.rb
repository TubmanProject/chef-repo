# Cookbook Name:: tubmanproject_docker
# Attribute:: default
#
# Copyright 2017, Tyrone Saunders. All Rights Reserved.

##########################
# Un-encrypted Data Bags #
##########################
default['deploy']['jupyterhub'] = Chef::DataBagItem.load('deploy', 'jupyterhub')