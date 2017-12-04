#
# Cookbook:: tubmanproject_app
# Recipe:: letsencrypt
#
# Copyright:: 2017, Tyrone Saunders, All Rights Reserved.

include_recipe "acme"

apps = node['deploy']['app'][node.chef_environment]

apps.each do |app|
  acme_ssl_certificate "#{app['subdomain']}.#{app['domain']}" do
    cn        "#{app['subdomain']}.#{app['domain']}"
    output    :fullchain
    crt       "#{node['app']['directories']['ssl']}/#{app['subdomain']}.#{app['domain']}/ssl.pem"
    key       "#{node['app']['directories']['ssl']}/#{app['subdomain']}.#{app['domain']}/ssl.key"
    wwwroot   "/var/#{app['domain']}/#{app['subdomain']}"
    webserver :nginx
    
    notifies :reload, 'service[nginx]'
  end
end