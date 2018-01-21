#
# Cookbook:: tubmanproject_rabbitmq
# Recipe:: selfsigned-certificate
#
# Copyright:: 2017, Tyrone Saunders, All Rights Reserved.

# create directory
directory node['rabbitmq']['directories']['ssl'] do
  owner "root"
  group "root"
  mode "0755"
  action :create
  recursive true
end

# create certificate
openssl_x509 "#{node['rabbitmq']['directories']['ssl']}/#{node['rabbitmq']['certfile_name']}" do
  common_name "#{node['secrets']['rabbitmq'][node.chef_environment]['hostname']}.#{node['secrets']['rabbitmq'][node.chef_environment]['domain']}"
  org node['secrets']['openssl']['distinguished_name']['organization_name']
  org_unit node['secrets']['openssl']['distinguished_name']['organizational_unit_name']
  country node['secrets']['openssl']['distinguished_name']['country']
  expire 1095
  owner 'root'
  mode '0400'
end

# generate dhparam.pem files
openssl_dhparam "#{node['rabbitmq']['directories']['ssl']}/dhparam.pem" do
  key_length 2048
  owner 'root'
  mode '0400'
end
