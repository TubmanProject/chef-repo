#
# Cookbook:: tubmanproject_base
# Recipe:: base
#
# Copyright:: 2017, Tyrone Saunders, All Rights Reserved.

node.override['authorization']['sudo']['users'] = ['ubuntu', 'vagrant']
node.override['authorization']['sudo']['passwordless'] = true

# include recipes as a run list
include_recipe  'apt'
include_recipe  'git'
include_recipe  'vim'
include_recipe  'sudo'
include_recipe  'users'
include_recipe  'openssl'
include_recipe  'sysctl::default'

package 'sysfsutils' do
  action :upgrade
end

service 'sysfsutils' do
  action :nothing
end

template '/etc/sysfs.conf' do
  source 'sysfs.conf.erb'
  owner 'root'
  group 'root'
  mode '0644'
  variables(
    :transparent_hugepage_defrag => 'never',
    :transparent_hugepage_enabled => 'never'
  )
  notifies :restart, 'service[sysfsutils]', :immediately
end

sysctl_param 'vm.overcommit_memory' do
  value 1
end

sysctl_param 'net.core.somaxconn' do
  value 512
end

#######################
# Add users to groups #
#######################
users_manage 'config-secrets'
users_manage 'sysadmin' do
  group_id 2300
  action [:create]
end

group 'config-secrets' do
  action :create
  append true
  members [node['ssh']['user'], node['app']['user']]
end

group node['app']['user'] do
  action :create
  append true
  members [node['ssh']['user']]
end

#############################
# set environment variables #
#############################
directory '/etc/profile.d'
template '/etc/profile.d/env_vars.sh' do
  source 'env_vars.sh.erb'
  variables(
    :env_vars => node['environment']['variables']
  )
  not_if { ::File.exist?('/etc/profile.d/env_vars.sh') }
end

####################################
# create configuration directories #
####################################
directory "#{node['env']['vars']['XDG_CONFIG_DIRS']}/.aws" do
  recursive true
  owner node['ssh']['user']
  group 'config-secrets'
  mode '0750'
end

##############################
# write AWS credentials file #
##############################
aws_credentials = {}
aws_credentials['region'] = node['secrets']['aws']['region']
aws_credentials['aws_access_key_id'] = node['secrets']['aws']['aws_access_key_id']
aws_credentials['aws_secret_access_key'] = node['secrets']['aws']['aws_secret_access_key']

# write the credentials file
template '/etc/xdg/.config/.aws/credentials' do
  source 'app.ini.erb' # borrow the template for app.ini from uWSGI
  mode '0550'
  owner node['ssh']['user']
  group 'config-secrets'
  variables(
    :name => 'default',
    :config => aws_credentials
  )
end

###################
# create ssh keys #
###################
ssh_keys = node['secrets']['ssh_keys'][node.chef_environment]

directory '/.ssh' do
  owner node['ssh']['user']
  mode '0700'
end

# public key
if !ssh_keys['public_key_filename'].empty?
  file "/.ssh/#{ssh_keys['public_key_filename']}" do
    content ssh_keys['public_key']
    owner node['ssh']['user']
    mode '0400'
  end
end

# private key
if !ssh_keys['private_key_filename'].empty?
  file "/.ssh/#{ssh_keys['private_key_filename']}" do
    content ssh_keys['private_key']
    owner node['ssh']['user']
    mode '0400'
  end
end

###############################
# Change system time and date #
###############################
bash 'change timzone' do
  code "timedatectl set-timezone #{node['timezone']}"
end
