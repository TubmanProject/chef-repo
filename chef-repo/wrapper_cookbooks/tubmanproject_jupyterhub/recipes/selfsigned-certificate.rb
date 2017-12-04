#
# Cookbook:: tubmanproject_jupyterhub
# Recipe:: selfsigned-certificate
#
# Copyright:: 2017, Tyrone Saunders, All Rights Reserved.

apps = node['deploy']['jupyterhub'][node.chef_environment]

apps.each do |app|
  # create directory
  directory "#{node['jupyterhub']['directories']['ssl']}/#{app['subdomain']}.#{app['domain']}" do
    owner "root"
    group "root"
    mode "0755"
    action :create
    recursive true
  end
  
  # create certificate
  openssl_x509 "#{node['jupyterhub']['directories']['ssl']}/#{app['subdomain']}.#{app['domain']}/ssl.pem" do
    common_name "#{app['subdomain']}.#{app['domain']}"
    org node['secrets']['openssl']['distinguished_name']['organization_name']
    org_unit node['secrets']['openssl']['distinguished_name']['organizational_unit_name']
    country node['secrets']['openssl']['distinguished_name']['country']
    expire 1095
    owner 'root'
    group 'root'
  end
  
  # generate dhparam.pem files
  openssl_dhparam "#{node['jupyterhub']['directories']['ssl']}/#{app['subdomain']}.#{app['domain']}/dhparam.pem" do
    key_length 2048
  end
end