#
# Cookbook:: tubmanproject_app
# Recipe:: selfsigned-certificate
#
# Copyright:: 2017, Tyrone Saunders, All Rights Reserved.

apps = node['deploy']['app'][node.chef_environment]

apps.each do |app|
  # create directory
  directory "#{node['app']['directories']['ssl']}/#{app['subdomain']}.#{app['domain']}" do
    owner "root"
    group "root"
    mode "0755"
    action :create
    recursive true
  end

  # create certificate
  if ['development'].include?(node.chef_environment)
    openssl_x509 "#{node['app']['directories']['ssl']}/#{app['subdomain']}.#{app['domain']}/ssl.pem" do
      common_name "#{app['subdomain']}.#{app['domain']}"
      org node['secrets']['openssl']['distinguished_name']['organization_name']
      org_unit node['secrets']['openssl']['distinguished_name']['organizational_unit_name']
      country node['secrets']['openssl']['distinguished_name']['country']
      expire 1095
      owner 'root'
      group 'root'
    end

    openssl_x509 "#{node['app']['directories']['ssl']}/#{app['subdomain']}.#{app['domain']}/#{app['subdomain']}.#{app['domain']}.pem" do
      common_name "#{app['subdomain']}.#{app['domain']}"
      org node['secrets']['openssl']['distinguished_name']['organization_name']
      org_unit node['secrets']['openssl']['distinguished_name']['organizational_unit_name']
      country node['secrets']['openssl']['distinguished_name']['country']
      expire 1095
      owner node['app']['user']
      group node['app']['user']
    end

  else
    include_recipe 'acme'
    acme_selfsigned "#{app['subdomain']}.#{app['domain']}" do
      cn "#{app['subdomain']}.#{app['domain']}"
      crt "#{node['app']['directories']['ssl']}/#{app['subdomain']}.#{app['domain']}/ssl.pem"
      key "#{node['app']['directories']['ssl']}/#{app['subdomain']}.#{app['domain']}/ssl.key"
      chain "#{node['app']['directories']['ssl']}/#{app['subdomain']}.#{app['domain']}/ssl-chain.pem"
    end

    openssl_x509 "#{node['app']['directories']['ssl']}/#{app['subdomain']}.#{app['domain']}/#{app['subdomain']}.#{app['domain']}.pem" do
      common_name "#{app['subdomain']}.#{app['domain']}"
      org node['secrets']['openssl']['distinguished_name']['organization_name']
      org_unit node['secrets']['openssl']['distinguished_name']['organizational_unit_name']
      country node['secrets']['openssl']['distinguished_name']['country']
      expire 1095
      owner node['app']['user']
      group node['app']['user']
    end
  end

  # generate dhparam.pem files
  openssl_dhparam "#{node['app']['directories']['ssl']}/#{app['subdomain']}.#{app['domain']}/dhparam.pem" do
    key_length 2048
  end
end
