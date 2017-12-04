#
# Cookbook:: tubmanproject_jupyterhub
# Recipe:: local-provisioning
#
# Copyright:: 2017, Tyrone Saunders, All Rights Reserved.

include_recipe "tubmanproject_base::base"
include_recipe "tubmanproject_github::ssh-wrapper"
include_recipe "tubmanproject_nginx::install"
include_recipe "tubmanproject_python::install"
include_recipe "tubmanproject_nodejs::install"
include_recipe "tubmanproject_supervisor::install"
include_recipe "tubmanproject_docker::install"
include_recipe "tubmanproject_docker::jupyterhub-image"
include_recipe "tubmanproject_jupyterhub::selfsigned-certificate"
include_recipe "tubmanproject_jupyterhub::deploy"