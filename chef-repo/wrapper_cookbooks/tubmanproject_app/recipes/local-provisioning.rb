#
# Cookbook:: tubmanproject_app
# Recipe:: local-provisioning
#
# Copyright:: 2017, Tyrone Saunders, All Rights Reserved.

include_recipe "tubmanproject_base::base"
include_recipe "tubmanproject_github::ssh-wrapper"
include_recipe "tubmanproject_nginx::install"
include_recipe "tubmanproject_python::install"
include_recipe "tubmanproject_supervisor::install"
include_recipe "tubmanproject_app::selfsigned-certificate"
include_recipe "tubmanproject_app::deploy"
include_recipe "tubmanproject_app::settings"