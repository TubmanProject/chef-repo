#
# Cookbook:: tubmanproject_aws
# Recipe:: monolith
#
# Copyright:: 2017, Tyrone Saunders, All Rights Reserved.

require "chef/provisioning/aws_driver"
with_driver "aws::#{node['secrets']['aws']['region']}"

# when deploying multiple programs to an EC2 instance assume all programs have the same domain
apps = node['deploy']['app'][node.chef_environment]
app = apps.first

######################
# Setup EC2 instance #
######################
machine "monolith.#{app['domain']}" do
  # copy chef data bag secret
  files "/etc/chef/encrypted_data_bag_secret" => "#{node['secrets']['host_machine']['project_path']}/#{node['secrets']['data_bag']['relative_path']}"
  chef_environment node.chef_environment
  machine_options({
    bootstrap_options: {
      image_id: node['secrets']['aws']['image_id'], # Ubuntu 16.04 LTS - Xenial (HVM) (US East N. Virginia)
      instance_type: node['secrets']['aws']['instance_type'],
      key_name: node['secrets']['aws']['aws_key_name'],
      key_path: node['secrets']['aws']['aws_key_path'],
      security_group_ids: ["webserver"],
      block_device_mappings: [
        {
          device_name: "/dev/sda1",
          ebs: {
            volume_size: 64
          }
        }
      ]
    },
    convergence_options: {
      chef_version: node['chef_client']['version']
    }
  }) 
end

elastic_ip = aws_eip_address "monolith.#{app['domain']}" do
  machine "monolith.#{app['domain']}"
end

machine "monolith.#{app['domain']}" do
  chef_environment node.chef_environment
  # set attributes
  attributes({
    :aws => {
      :elastic_ip => elastic_ip.aws_object.public_ip
    }
  })
  # recipe run list
  recipe "tubmanproject_base::base"
  recipe "tubmanproject_hosts::hosts"
  recipe "tubmanproject_github::ssh-wrapper"
  recipe "tubmanproject_nginx::install"
  recipe "tubmanproject_python::install"
  recipe "tubmanproject_nodejs::install"
  recipe "tubmanproject_supervisor::install"
  recipe "tubmanproject_docker::install"
  recipe "tubmanproject_jupyterhub::selfsigned-certificate"
  recipe "tubmanproject_jupyterhub::deploy"
  recipe "tubmanproject_jupyterhub::letsencrypt"
  recipe "gtubmanproject_app::selfsigned-certificate"
  recipe "tubmanproject_app::deploy"
  recipe "tubmanproject_app::letsencrypt"
  recipe "tubmanproject_supervisor::restart"
  machine_options({
    convergence_options: {
      chef_version: node['chef_client']['version']
    }
  })
end
