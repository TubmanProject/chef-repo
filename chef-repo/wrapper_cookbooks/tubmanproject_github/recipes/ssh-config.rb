#
# Cookbook:: tubmanproject_github
# Recipe:: ssh-config
#
# Copyright:: 2017, Tyrone Saunders, All Rights Reserved.

github_secrets = node['secrets']['github'][node.chef_environment]

# create .ssh directory
directory "#{::Dir.home(node['ssh']['user'])}/.ssh" do
  owner node['ssh']['user']
  group node['ssh']['user']
  recursive true
end

# copy identity files to .ssh directory
# public key
file "#{::Dir.home(node['ssh']['user'])}/.ssh/#{github_secrets['public_key_filename']}" do
  content github_secrets['public_key']
  owner node['ssh']['user']
  mode 0400
end

# private key
file "#{::Dir.home(node['ssh']['user'])}/.ssh/#{github_secrets['private_key_filename']}" do
  content github_secrets['private_key']
  owner node['ssh']['user']
  mode 0400
end

# create ssh config file
template "#{::Dir.home(node['ssh']['user'])}/.ssh/config" do
  owner node['ssh']['user']
  mode 0600
  source "ssh-config.erb"
  variables({
    :identity_file => "#{::Dir.home(node['ssh']['user'])}/.ssh/#{github_secrets['private_key_filename']}"
  })
end