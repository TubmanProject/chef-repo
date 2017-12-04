#
# Cookbook:: tubmanproject_aws
# Recipe:: bootstrap
#
# Copyright:: 2017, Tyrone Saunders, All Rights Reserved.

# when deploying multiple programs to an EC2 instance assume all programs have the same domain
apps = node['deploy']['app'][node.chef_environment]
app = apps.first

execute "bootstrap EC2 node" do
  cmd = "knife ec2 server create"
  cmd += " --flavor #{node['secrets']['aws']['instance_type']}"
  cmd += " --image #{node['secrets']['aws']['image_id']}" # Ubuntu 16.04 LTS - Xenial (HVM) (US East N. Virginia)
  cmd += " --security-group-id webserver"
  cmd += " --node-name monolith.#{app['domain']}"
  cmd += " --ssh-user ubuntu"
  cmd += " --identity-file #{node['secrets']['aws']['aws_key_path']}/#{node['secrets']['aws']['aws_key_name']}.pem"
  cmd += " --bootstrap-version 12.19.36"
  cmd += " --config #{node['secrets']['host_machine']['project_path']}/chef-repo/.chef/config.rb"
  cmd += " --environment production"
  command cmd
end
