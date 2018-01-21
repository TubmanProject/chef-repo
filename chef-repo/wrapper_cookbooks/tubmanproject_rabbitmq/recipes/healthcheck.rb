#
# Cookbook:: tubmanproject_rabbitmq
# Recipe:: healthcheck
#
# Copyright:: 2017, Tyrone Saunders, All Rights Reserved.

#############
# variables #
#############
ssh_wrapper = node['secrets']['github'][node.chef_environment]
env_vars = {}
env_vars['NODE_ENV'] = node.chef_environment

if !['staging', 'production'].include? node.chef_environment
  env_vars['DEBUG'] = "rabbitmq_health:*"
end

###############
# Directories #
###############
directory '/var/log/rabbitmq' do
  owner node['app']['user']
  group 'www-data'
  mode '0755'
  recursive true
end

##############
# Deployment #
##############
# retrieve configuration details from data bag
healthchecks = node['deploy']['rabbitmq-healthcheck'][node.chef_environment]

healthchecks.each do |healthcheck|
  name = healthcheck['name']
  subdomain = healthcheck['subdomain']
  domain = healthcheck['domain']
  port = healthcheck['port']
  force_ssl = healthcheck['ssl']
  nginx_template = healthcheck['nginx_config_template']

  if subdomain == 'www'
    server_name = domain
  else
    server_name = "#{subdomain}.#{domain}"
  end

  env_vars['RABBITMQ_PORT'] = node['rabbitmq']['port']
  env_vars["APP_NAME"] = name
  env_vars["#{name.upcase}_PORT"] = port

  #######################
  # Deploy app (github) #
  #######################
  # create the directory for the application
  directory "/var/#{domain}/#{subdomain}" do
    owner node['ssh']['user']
    group 'www-data'
    mode '0755'
    action :create
    recursive true
  end

  # get repository url
  repository = healthcheck['git']['repository']
  branch = healthcheck['git']['branch']

  ##### Deploy the web application - use synced folder if development env else use github #####
  if ['staging', 'production'].include? node.chef_environment
    git "/var/#{domain}/#{subdomain}" do
      repository repository
      revision branch
      ssh_wrapper "#{ssh_wrapper['keypair_path']}/#{ssh_wrapper['ssh_wrapper_filename']}"
      environment(
        lazy {
          {
            'HOME' => ::Dir.home(node['ssh']['user']),
            'USER' => node['ssh']['user']
          }
        }
      )
      group 'www-data'
      user node['ssh']['user']
      action :sync
    end
  end

  # install apt packages
  healthcheck['apt'].each do |apt_package|
    package apt_package do
      action :upgrade
    end
  end

  # install npm packages
  healthcheck['npm']['global'].each do |npm_package|
     nodejs_npm npm_package
  end

  healthcheck['npm']['local'].each do |npm_package|
     nodejs_npm npm_package do
       path "/var/#{domain}/#{subdomain}/healthcheck"
     end
  end

  # run npm install
  nodejs_npm "install packages for #{name}" do
    path "/var/#{domain}/#{subdomain}/healthcheck"
    json true
  end

  # configure pm2
  pm2_app = {}
  pm2_app['name'] = name
  pm2_app['script'] = "/var/#{domain}/#{subdomain}/healthcheck/app.js"
  pm2_app['cwd'] = "/var/#{domain}/#{subdomain}/healthcheck"
  pm2_app['error_file'] = "/var/log/rabbitmq/#{name}.stderr.log"
  pm2_app['out_file'] = "/var/log/rabbitmq/#{name}.stdout.log"
  pm2_app['watch'] = true
  pm2_app['env'] = env_vars

  node.override['pm2']['app_names'][pm2_app['name']] = pm2_app
  node.override['pm2']['ecosystem']['apps'] = node['pm2']['app_names'].values

  # set up nginx as a reverse proxy server
  nginx_site server_name do
    action :enable
    template nginx_template
    variables(
      default: false,
      sendfile: 'off',
      force_ssl: force_ssl,
      subdomain: subdomain,
      domain: domain,
      server_name: server_name,
      port: port,
      ssl_directory: node['rabbitmq']['directories']['ssl'],
      ssl_keyfile_name: node['rabbitmq']['keyfile_name'],
      ssl_certfile_name: node['rabbitmq']['certfile_name']
    )
  end
end

# get healthcheck subdomain and domain
healthcheck = healthchecks.first

# create directory for pm2 ecosystem file
directory "/var/#{healthcheck['domain']}/pm2/" do
  recursive true
end

# write the pm2 ecosystem file
file "/var/#{healthcheck['domain']}/pm2/ecosystem.json" do
  content Chef::JSONCompat.to_json_pretty(node['pm2']['ecosystem'])
  action :create # If a file already exists (but does not match), update that file to match.
end

# run commands
healthcheck['commands'].each do |cmd|
  execute "run #{cmd} command" do
    live_stream true
    user node['ssh']['user']
    group node['ssh']['user']
    environment(
      lazy {
        {
          'HOME' => ::Dir.home(node['ssh']['user']),
          'USER' => node['ssh']['user']
        }
      }
    )
    cwd "/var/#{healthcheck['domain']}/#{healthcheck['subdomain']}/healthcheck"
    command cmd
  end
end
