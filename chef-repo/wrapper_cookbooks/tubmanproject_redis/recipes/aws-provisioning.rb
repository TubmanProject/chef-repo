#
# Cookbook:: tubmanproject_redis
# Recipe:: aws-provisioning
#
# Copyright:: 2017, Tyrone Saunders, All Rights Reserved.

Chef::Recipe.send(:include, OpenSSLCookbook::RandomPassword)

require 'chef/provisioning/aws_driver'
with_driver "aws::#{node['secrets']['aws']['region']}"

master = node['secrets']['redis'][node.chef_environment]['master']
replicas = node['secrets']['redis'][node.chef_environment]['replicas']

##########################
# Provision Redis Master #
##########################
machine "#{master['name']}.#{node['secrets']['redis'][node.chef_environment]['domain']}" do
  files '/etc/chef/encrypted_data_bag_secret' => "#{node['secrets']['host_machine']['project_path']}/#{node['secrets']['data_bag']['relative_path']}"
  recipe 'tubmanproject_base::base'
  recipe 'tubmanproject_github::ssh-wrapper'
  recipe 'tubmanproject_redis::selfsigned-certificate'
  recipe 'tubmanproject_nodejs::install'
  recipe 'tubmanproject_nginx::install'
  recipe 'tubmanproject_redis::master'
  recipe 'tubmanproject_redis::install'
  chef_environment node.chef_environment
  machine_options(
    bootstrap_options: {
      image_id: node['secrets']['aws']['instance_type'], # "ami-2c57433b" == Ubuntu 16.04 LTS - Xenial (HVM) (US East N. Virginia)
      instance_type: node['secrets']['aws']['instance_type'],
      key_name: node['secrets']['aws']['aws_key_name'],
      key_path: node['secrets']['aws']['aws_key_path'],
      security_group_ids: ['redis']
    }
  )
end

# search chef server for EC2 attributes
redis_ec2_instances = search(:node, "name:#{master['name']}*")
redis_ec2_instances.each do |redis_ec2|
  node.override['redisio']['master']['ip']['public'] = redis_ec2['ec2']['public_ipv4']
  node.override['redisio']['master']['ip']['private'] = redis_ec2['ec2']['local_ipv4']
end

##########################
# Provision Redis Slaves #
##########################
# secure read-only redis slave instance by obfusticating admin commands
rename_commands = {}
rename_commands['CONFIG'] = random_password(length: 8)
rename_commands['DEBUG'] = random_password(length: 8)
rename_commands['FLUSHDB'] = random_password(length: 8)
rename_commands['FLUSHALL'] = random_password(length: 8)
rename_commands['SHUTDOWN'] = random_password(length: 8)

replicas.each do |replica|
  config_settings = {}
  config_settings['rename_commands'] = rename_commands
  config_settings['port'] = replica['port']
  config_settings['name'] = "#{replica['name']}.#{node['secrets']['redis'][node.chef_environment]['domain']}"
  config_settings['masterauth'] = replica['master_auth']
  config_settings['keepalive'] = 60
  config_settings['backuptype'] = "both"
  config_settings['logfile'] = "/var/log/redis/#{replica['name']}.#{node['secrets']['redis'][node.chef_environment]['domain']}.log"
  config_settings['syslogenabled'] = "no"
  config_settings['slaveof'] = {}
  config_settings['slaveof']['address'] = node['redisio']['master']['ip']['public']
  config_settings['slaveof']['port'] = master['port']

  # provision AWS EC2 instances
  machine "#{replica['name']}.#{node['secrets']['redis'][node.chef_environment]['domain']}" do
    files '/etc/chef/encrypted_data_bag_secret' => "#{node['secrets']['host_machine']['project_path']}/#{node['secrets']['data_bag']['relative_path']}"
    # set attributes
    attributes({
      "redisio" => {
        "servers" => {
          "#{config_settings['name']}" => config_settings
        },
        "slave" => {
          "servers" => {
            "#{config_settings['name']}" => config_settings
          },
          "server" => {
            "current" => config_settings
          }
        }
      }
    })
    # install redis
    recipe 'tubmanproject_base::base'
    recipe 'tubmanproject_github::ssh-wrapper'
    recipe 'tubmanproject_redis::selfsigned-certificate'
    recipe 'tubmanproject_nodejs::install'
    recipe 'tubmanproject_nginx::install'
    recipe 'tubmanproject_redis::install'
    chef_environment node.chef_environment
    machine_options(
      bootstrap_options: {
        image_id: node['secrets']['aws']['instance_type'], # "ami-2c57433b" == Ubuntu 16.04 LTS - Xenial (HVM) (US East N. Virginia)
        instance_type: node['secrets']['aws']['instance_type'],
        key_name: node['secrets']['aws']['aws_key_name'],
        key_path: node['secrets']['aws']['aws_key_path'],
        security_group_ids: ['redis']
      }
    )
  end
end
