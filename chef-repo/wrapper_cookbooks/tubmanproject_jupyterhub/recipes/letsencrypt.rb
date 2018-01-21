#
# Cookbook:: tubmanproject_jupyterhub
# Recipe:: letsencrypt
#
# Copyright:: 2017, Tyrone Saunders, All Rights Reserved.

include_recipe 'acme'

apps = node['deploy']['jupyterhub'][node.chef_environment]

apps.each do |app|
  if app['acme_cert']['requested'] && app['acme_cert']['challenge'] == 'tls-sni-01'
    acme_ssl_certificate "#{node['jupyterhub']['directories']['ssl']}/#{app['subdomain']}.#{app['domain']}/ssl.pem" do
      cn            "#{app['subdomain']}.#{app['domain']}"
      output        :fullchain
      key           "#{node['jupyterhub']['directories']['ssl']}/#{app['subdomain']}.#{app['domain']}/ssl.key"
      webserver     :nginx
      notifies      :reload, 'service[nginx]'
    end
  end

  if app['acme_cert']['requested'] && app['acme_cert']['challenge'] == 'http-01'
    acme_certificate "#{app['subdomain']}.#{app['domain']}" do
      cn        "#{app['subdomain']}.#{app['domain']}"
      crt       "#{node['jupyterhub']['directories']['ssl']}/#{app['subdomain']}.#{app['domain']}/ssl.pem"
      chain     "#{node['jupyterhub']['directories']['ssl']}/#{app['subdomain']}.#{app['domain']}/ssl-chain.pem"
      key       "#{node['jupyterhub']['directories']['ssl']}/#{app['subdomain']}.#{app['domain']}/ssl.key"
      wwwroot   "/.acme-cert/#{app['domain']}/#{app['subdomain']}"
      notifies  :reload, 'service[nginx]'
    end
  end
end
