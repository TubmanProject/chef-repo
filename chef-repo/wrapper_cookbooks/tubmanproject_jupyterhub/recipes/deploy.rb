#
# Cookbook:: tubmanproject_jupyterhub
# Recipe:: deploy
#
# Copyright:: 2017, Tyrone Saunders, All Rights Reserved.

Chef::Recipe.send(:include, OpenSSLCookbook::RandomPassword)

#############
# variables #
#############
ssh_wrapper = node['secrets']['github'][node.chef_environment]
oauth = node['secrets']['oauth'][node.chef_environment]
env_vars = {
  "HOME" => ::Dir.home(node['jupyterhub']['user']),
  "APPLICATION_MODE" => node.chef_environment.upcase,
  "CONFIGPROXY_AUTH_TOKEN" => random_password(length: 32, mode: :hex),
  "GITHUB_CLIENT_ID" => oauth['github']['client_id'],
  "GITHUB_CLIENT_SECRET" => oauth['github']['client_secret'],
  "OAUTH_CLIENT_ID" => oauth['github']['client_id'],
  "OAUTH_CLIENT_SECRET" => oauth['github']['client_secret']
}

###############
# Directories #
###############
directory node['jupyterhub']['directories']['runtime'] do
  mode '0755'
  recursive true
end

directory node['jupyterhub']['directories']['configuration'] do
  mode '0770'
  recursive true
end

directory node['jupyterhub']['directories']['log'] do
  mode '0755'
  recursive true
end

##############
# Deployment #
##############
# retrieve configuration details from data bag
apps = node['deploy']['jupyterhub'][node.chef_environment]

apps.each do |app|
  
  #############
  # variables #
  #############
  subdomain = app['subdomain']
  domain = app['domain']
  port = app['port']
  force_ssl = app['ssl']
  nginx_template = app['nginx_config_template']
  cookie_secret = random_password(length: 32, mode: :hex)
  proxy_auth_token = random_password(length: 32, mode: :hex)
  env_vars['PYTHON_PORT'] = app['port']
  env_vars['OAUTH_CALLBACK_URL'] = "https://#{subdomain}.#{domain}/hub/oauth_callback"
  
  if subdomain == 'www'
    server_name = domain
  else
    server_name = "#{subdomain}.#{domain}"
  end
  
  ###########################
  # Deploy app (github) #
  ###########################
  repository = app['git']['repository']
  branch = app['git']['branch']
  jupyterhub_config = app['config']['jupyterhub']
  programs = app['programs']
  if app['config']['jupyterhub']['docker']['build']
    dockerspawner_image = "jupyterhub-image/#{app['subdomain']}.#{app['domain']}"
  else
    dockerspawner_image = "#{app['config']['jupyterhub']['docker']['image']}:#{app['config']['jupyterhub']['docker']['tag']}"
  end
  
  
  # create the directory for the application
  directory "/var/#{domain}/#{subdomain}" do
    owner node['ssh']['user']
    group 'www-data'
    mode '0775'
    action :create
    recursive true
  end
  
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
  app['apt'].each do |apt_package|
    package apt_package do
      action :upgrade
    end
  end
  
  # install npm packages
  app['npm']['global'].each do |npm_package|
     nodejs_npm npm_package
  end
  
  app['npm']['local'].each do |npm_package|
     nodejs_npm npm_package do
       path "/var/#{domain}/#{subdomain}"
     end
  end 
  
  # create a directory for the virtualenv
  directory "/var/#{domain}/#{subdomain}/.venv" do
    user 'www-data'
    group 'www-data'
    mode '0755'
    recursive true
    action :create
  end
  
  # create and activate virtual env
  python_virtualenv "/var/#{domain}/#{subdomain}/.venv" do
    python '3' # for the python runtime use the "system" version of python
    user 'www-data'
    group 'www-data'
  end
  
  # install pip packages from requirements.txt
  pip_requirements "/var/#{domain}/#{subdomain}/requirements.txt" do
    virtualenv "/var/#{domain}/#{subdomain}/.venv"
    group 'www-data'
    user node['jupyterhub']['user'] 
  end
   
  # create a kernel
  python_execute "create ipykernel" do
    python '3'
    virtualenv "/var/#{domain}/#{subdomain}/.venv"
    command "-m ipykernel install --sys-prefix --name ipykernel-#{domain}.#{subdomain} --display-name 'Python 3 (#{domain}.#{subdomain})'"
    user node['jupyterhub']['user']
    environment(
      lazy {
        {
          'HOME' => ::Dir.home(node['jupyterhub']['user']),
          'USER' => node['jupyterhub']['user']
        }
      }
    ) 
  end
  
  # generate the cookie secret
  file "#{node['jupyterhub']['directories']['runtime']}/#{subdomain}.#{domain}_cookie_secret" do
    owner node['jupyterhub']['user']
    mode '0600'
    content cookie_secret
  end
  
  #  jupyterhub_config.py
  template "#{node['jupyterhub']['directories']['configuration']}/#{subdomain}.#{domain}_config.py" do
    source "jupyterhub_config.py.erb"
    owner node['jupyterhub']['user']
    mode '0500'
    variables(
      :subdomain => subdomain,
      :domain => domain,
      :runtime_directory => node['jupyterhub']['directories']['runtime'],
      :ssl_directory => node['jupyterhub']['directories']['ssl'],
      :log_directory => node['jupyterhub']['directories']['log'],
      :port => port,
      :ssl_key_filename => "ssl.key",
      :ssl_cert_filename => "ssl.pem",
      :proxy_auth_token => proxy_auth_token,
      :admin_access => node['jupyterhub']['admin_access'].to_s.capitalize,
      :whitelist => node['secrets']['jupyterhub_users'][node.chef_environment]['whitelist'],
      :admin_users => node['secrets']['jupyterhub_users'][node.chef_environment]['admin'],
      :create_system_users => node['jupyterhub']['create_system_users'].to_s.capitalize,
      :notebook_dir => "/var/#{domain}/#{subdomain}/jupyterhub/notebooks",
      :disable_user_config => node['jupyterhub']['disable_user_config'].to_s.capitalize,
      :dockerspawner_image => dockerspawner_image
    )
  end
  
  # run commands
  app['commands'].each do |cmd|
    execute "run #{cmd} command" do
      live_stream true
      user node['ssh']['user']
      environment(
        lazy {
          {
            'HOME' => ::Dir.home(node['ssh']['user']),
            'USER' => node['ssh']['user']
          }
        }
      )
      cwd "/var/#{domain}/#{subdomain}"
      command cmd
    end
  end
  
  # setup programs running under supervisor
  programs.each_pair do |program_name, program_config|
    # configure supervisor program scripts
    program_config['user'] = node['jupyterhub']['user']
    program_config['environment'] = env_vars.keys.map{|key| "#{key}=#{env_vars[key]}"}.join(",")
    
    template "/etc/supervisor/conf.d/#{program_name}.conf" do
      source "supervisor_program.conf.erb"
      variables(
        :program_name => program_name,
        :program_config => program_config
      )
    end 
  end # programs.each_pair do |program_name, program_config|
  
  # setup nginx configuration 
  nginx_site server_name do
    action :enable
    template nginx_template
    variables(
      :default => false,
      :sendfile => 'off',
      :force_ssl => force_ssl,
      :subdomain => subdomain,
      :domain => domain,
      :port => port,
      :ssl_directory => node['jupyterhub']['directories']['ssl']
    )
  end
end
