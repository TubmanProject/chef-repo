#
# Cookbook:: tubmanproject_mongodb
# Recipe:: selfsigned-certificate
#
# Copyright:: 2017, Tyrone Saunders, All Rights Reserved.

user node['mongodb']['user'] do
  action :create
end

# create directory
directory "#{node['mongodb']['directories']['ssl']}" do
  owner "root"
  group "root"
  mode "0755"
  action :create
  recursive true
end

# create certificate
openssl_x509 "#{node['mongodb']['directories']['ssl']}/#{node['mongodb']['certfile_name']}" do
  common_name "#{node['secrets']['mongodb'][node.chef_environment]['hostname']}.#{node['secrets']['mongodb'][node.chef_environment]['domain']}"
  org node['secrets']['openssl']['distinguished_name']['organization_name']
  org_unit node['secrets']['openssl']['distinguished_name']['organizational_unit_name']
  country node['secrets']['openssl']['distinguished_name']['country']
  expire 1095
  owner 'root'
  mode '0400'
end

# combine certfile and key file
bash 'concatenate the certificate and private key' do
  code <<-EOH
    cat #{node['mongodb']['directories']['ssl']}/#{node['mongodb']['keyfile_name']} #{node['mongodb']['directories']['ssl']}/#{node['mongodb']['certfile_name']} > #{node['mongodb']['directories']['ssl']}/#{node['mongodb']['pem_keyfile_name']}
    chown #{node['mongodb']['user']} #{node['mongodb']['directories']['ssl']}/#{node['mongodb']['pem_keyfile_name']}
    chmod 0400 #{node['mongodb']['directories']['ssl']}/#{node['mongodb']['pem_keyfile_name']}
    EOH
end

# generate dhparam.pem files
openssl_dhparam "#{node['mongodb']['directories']['ssl']}/dhparam.pem" do
  key_length 2048
  owner 'root'
  mode '0400'
end
