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
machine "tubmanproject.#{app['domain']}" do
  # copy chef data bag secret
  files "/etc/chef/encrypted_data_bag_secret" => "#{node['secrets']['host_machine']['project_path']}/#{node['secrets']['data_bag']['relative_path']}"
  chef_environment node.chef_environment
  # recipe run list
  recipe 'tubmanproject_base::base'
  machine_options({
    bootstrap_options: {
      image_id: node['secrets']['aws']['image_id'], # Ubuntu 16.04 LTS - Xenial (HVM) (US East N. Virginia)
      instance_type: node['secrets']['aws']['instance_type'],
      key_name: node['secrets']['aws']['aws_key_name'],
      key_path: node['secrets']['aws']['aws_key_path'],
      security_group_ids: ['webserver'],
      block_device_mappings: [
        {
          device_name: '/dev/sda1',
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

elastic_ip = aws_eip_address "tubmanproject.#{app['domain']}" do
  machine "tubmanproject.#{app['domain']}"
end

machine "tubmanproject.#{app['domain']}" do
  chef_environment node.chef_environment
  # set attributes
  attributes({
    :aws => {
      :elastic_ip => elastic_ip.aws_object.public_ip
    }
  })
  # recipe run list
  remove_recipe 'tubmanproject_base::base'
  role 'production'
  role 'letsencrypt'
  machine_options({
    convergence_options: {
      chef_version: node['chef_client']['version']
    }
  })
end
