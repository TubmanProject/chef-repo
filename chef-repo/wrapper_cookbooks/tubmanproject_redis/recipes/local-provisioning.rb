#
# Cookbook:: tubmanproject_redis
# Recipe:: local-provisioning
#
# Copyright:: 2017, Tyrone Saunders, All Rights Reserved.

include_recipe "tubmanproject_base::base"
include_recipe "tubmanproject_redis::master"
include_recipe "tubmanproject_redis::slave"
include_recipe "tubmanproject_redis::install"
