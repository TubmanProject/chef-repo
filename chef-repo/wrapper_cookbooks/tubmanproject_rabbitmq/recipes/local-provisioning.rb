#
# Cookbook:: tubmanproject_rabbitmq
# Recipe:: local-provisioning
#
# Copyright:: 2017, Tyrone Saunders, All Rights Reserved.

include_recipe 'tubmanproject_base::base'

###############################################################
# cookbook doesn't support multiple nodes on a single machine #
###############################################################
include_recipe 'tubmanproject_rabbitmq::single'
