#
# Cookbook:: tubmanproject_app
# Recipe:: settings
#
# Copyright:: 2017, Tyrone Saunders, All Rights Reserved.

Chef::Recipe.send(:include, OpenSSLCookbook::RandomPassword)

apps = node['deploy']['app'][node.chef_environment]

apps.each do |app|
  app_settings = {}
  app_settings['SECRET_KEY'] = random_password(length: 24)
  app_settings['PYTHON_PORT'] = app['port']
  app_settings['SUBDOMAIN'] = app['subdomain']
  app_settings['DOMAIN_NAME'] = app['domain']
  app_settings['SERVER_NAME'] = "#{app['subdomain']}.#{app['domain']}"
  app_settings['MAIL_SERVER'] = "mail.#{app['domain']}"
  app_settings['SSL_CERTFILE'] = "#{node['app']['directories']['ssl']}/#{app['subdomain']}.#{app['domain']}/#{app['subdomain']}.#{app['domain']}.pem"
  app_settings['SSL_KEYFILE'] = "#{node['app']['directories']['ssl']}/#{app['subdomain']}.#{app['domain']}/#{app['subdomain']}.#{app['domain']}.key"
  app_settings['HOSTNAME'] = app['hostname']


  node.override['app']['settings'] = app_settings

  ####################################
  # create configuration directories #
  ####################################
  group 'config-secrets' do
    action :modify
    append true
    members [node['ssh']['user'], node['app']['user']]
  end

  directory "/etc/xdg/.config/#{app['subdomain']}.#{app['domain']}" do
    recursive true
    owner node['ssh']['user']
    group 'config-secrets'
    mode '0750'
  end

  #######################
  # write a config file #
  #######################
  file "/etc/xdg/.config/#{app['subdomain']}.#{app['domain']}/secrets.json" do
    content lazy {Chef::JSONCompat.to_json_pretty(node['app']['settings'])}
    owner node['ssh']['user']
    group 'config-secrets'
    mode '0550'
  end
end
