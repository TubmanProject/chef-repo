#
# Cookbook:: tubmanproject_redis
# Recipe:: selfsigned-certificate
#
# Copyright:: 2017, Tyrone Saunders, All Rights Reserved.

# create directory
directory node['redisio']['directories']['ssl'] do
  owner "root"
  group "root"
  mode "0755"
  action :create
  recursive true
end

# create certificate
openssl_x509 "#{node['redisio']['directories']['ssl']}/#{node['redisio']['certfile_name']}" do
  common_name "#{node['secrets']['redis'][node.chef_environment]['hostname']}.#{node['secrets']['redis'][node.chef_environment]['domain']}"
  org node['secrets']['openssl']['distinguished_name']['organization_name']
  org_unit node['secrets']['openssl']['distinguished_name']['organizational_unit_name']
  country node['secrets']['openssl']['distinguished_name']['country']
  expire 1095
  owner 'root'
  mode '0400'
end

# generate dhparam.pem files
openssl_dhparam "#{node['redisio']['directories']['ssl']}/dhparam.pem" do
  key_length 2048
  owner 'root'
  mode '0400'
end
