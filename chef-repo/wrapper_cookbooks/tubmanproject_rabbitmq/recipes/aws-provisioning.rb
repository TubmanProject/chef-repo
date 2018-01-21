#
# Cookbook:: tubmanproject_rabbitmq
# Recipe:: aws-provisioning
#
# Copyright:: 2017, Tyrone Saunders, All Rights Reserved.

require 'chef/provisioning/aws_driver'
with_driver "aws::#{node['secrets']['aws']['region']}"

rabbitmq_clusters = node['secrets']['rabbitmq'][node.chef_environment]['cluster_nodes']

##########################
# Setup EC2 instances #
##########################
rabbitmq_clusters.each do |rabbitmq_node|
  machine "#{rabbitmq_node['nodename']}.#{node['secrets']['rabbitmq'][node.chef_environment]['domain']}" do
    attributes(
      rabbitmq: {
        port: rabbitmq_node['port'],
        clustering: {
          enable: true,
          current: {
            nodename: rabbitmq_node['nodename']
          }
        }
      }
    )
    files '/etc/chef/encrypted_data_bag_secret' => "#{node['secrets']['host_machine']['project_path']}/#{node['secrets']['data_bag']['relative_path']}"
    recipe 'tubmanproject_base::base'
    recipe 'tubmanproject_github::ssh-wrapper'
    recipe 'tubmanproject_rabbitmq::selfsigned-certificate'
    recipe 'tubmanproject_nodejs::install'
    recipe 'tubmanproject_nginx::install'
    chef_environment node.chef_environment
    machine_options(
      bootstrap_options: {
        image_id: node['secrets']['aws']['instance_type'], # "ami-2c57433b" == Ubuntu 16.04 LTS - Xenial (HVM) (US East N. Virginia)
        instance_type: node['secrets']['aws']['instance_type'],
        key_name: node['secrets']['aws']['aws_key_name'],
        key_path: node['secrets']['aws']['aws_key_path'],
        security_group_ids: ['rabbitmq']
      }
    )
  end
end

###############################
# RabbitMQ Cluster attributes #
###############################
# search chef server for EC2 attributes
ec2_instances = search(:node, "name:rabbit*.#{node['secrets']['rabbitmq'][node.chef_environment]['domain']}")

# set the cluster_nodes attribute
cluster_nodes = []
ec2_instances.each do |ec2_instance|
  cluster_node = {}
  cluster_node['name'] = "#{ec2_instance['rabbitmq']['clustering']['current']['nodename']}@#{ec2_instance['ec2']['hostname']}"
  cluster_node['type'] = 'disc'
  cluster_nodes.push(cluster_node)
end

###########################
# Provision EC2 instances #
###########################
ec2_instances.each do |ec2_instance|
  machine ec2_instance['name'] do
    # set attributes
    attributes(
      rabbitmq: {
        address: ec2_instance['ipaddress'],
        nodename: "#{ec2_instance['rabbitmq']['clustering']['current']['nodename']}@#{ec2_instance['ec2']['hostname']}",
        clustering: {
          cluster_nodes: cluster_nodes
        }
      }
    )
    # recipe run list
    recipe 'tubmanproject_base::default'
    recipe 'tubmanproject_rabbitmq::cluster'
  end
end
