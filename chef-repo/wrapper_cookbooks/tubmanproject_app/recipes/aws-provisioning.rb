#
# Cookbook:: tubmanproject_app
# Recipe:: aws-provisioning
#
# Copyright:: 2017, Tyrone Saunders, All Rights Reserved.

require "chef/provisioning/aws_driver"
with_driver "aws::#{node['secrets']['aws']['region']}"

apps = node['deploy']['app'][node.chef_environment]

##########################
# Setup EC2 instances #
##########################
# when deploying multiple programs to an EC2 instance assume all programs have the same domain
# the tubmanproject_app::deploy recipe sets up nginx server blocks with different directories serving as each program's root
app = apps.first

machine "monolith.#{app['domain']}" do
  # copy chef data bag secret
  files "/etc/chef/encrypted_data_bag_secret" => "#{node['secrets']['host_machine']['project_path']}/#{node['secrets']['data_bag']['relative_path']}"
  # recipe run list
  recipe "tubmanproject_base::base"
  recipe "tubmanproject_github::ssh-wrapper"
  recipe "tubmanproject_nginx::install"
  recipe "tubmanproject_python::install"
  recipe "tubmanproject_supervisor::install"
  recipe "tubmanproject_app::selfsigned-certificate"
  recipe "tubmanproject_app::deploy"
  recipe "tubmanproject_app::settings"
  chef_environment node.chef_environment
  machine_options({
    bootstrap_options: {
      image_id: node['secrets']['aws']['instance_type'], #"ami-2c57433b" == Ubuntu 16.04 LTS - Xenial (HVM) (US East N. Virginia)
      instance_type: node['secrets']['aws']['instance_type'],
      key_name: node['secrets']['aws']['aws_key_name'],
      key_path: node['secrets']['aws']['aws_key_path'],
      security_group_ids: ["webserver"] # create a webserver security group from the AWS management console
    }
  })
end