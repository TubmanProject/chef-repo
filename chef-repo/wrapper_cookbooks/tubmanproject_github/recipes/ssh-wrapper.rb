#
# Cookbook:: tubmanproject_github
# Recipe:: ssh-wrapper
#
# Copyright:: 2017, Tyrone Saunders, All Rights Reserved.

# retrieve configuration details from data bag
ssh_wrapper = node['secrets']['github'][node.chef_environment]

# create directory for the ssh wrapper
directory ssh_wrapper['keypair_path'] do
  owner node['ssh']['user']
  recursive true
end

# transfer wrapper script from cookbook to the node
template "#{ssh_wrapper['keypair_path']}/#{ssh_wrapper['ssh_wrapper_filename']}" do
  source "ssh_4_github.sh.erb"
  owner node['ssh']['user']
  mode 0755
  variables(
    :private_key_path => ssh_wrapper['keypair_path'],
    :private_key_filename => ssh_wrapper['private_key_filename']
  )
end

# public key
file "#{ssh_wrapper['keypair_path']}/#{ssh_wrapper['public_key_filename']}" do
  content ssh_wrapper['public_key']
  owner node['ssh']['user']
  mode 0600
end

# private key
file "#{ssh_wrapper['keypair_path']}/#{ssh_wrapper['private_key_filename']}" do
  content ssh_wrapper['private_key']
  owner node['ssh']['user']
  mode 0600
end