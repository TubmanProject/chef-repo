#
# Cookbook:: tubmanproject_app
# Recipe:: deploy
#
# Copyright:: 2017, Tyrone Saunders, All Rights Reserved.

#############
# variables #
#############
ssh_wrapper = node['secrets']['github'][node.chef_environment]
env_vars = {
  "HOME" => ::Dir.home(node['app']['user']),
  "APPLICATION_MODE" => node.chef_environment.upcase,
  "XDG_CONFIG_DIRS" => "/etc/xdg/.config",
  "APP_SECRETS_PATH" => "/etc/xdg/.config",
  "AWS_SHARED_CREDENTIALS_FILE" => "/etc/xdg/.config/.aws/credentials"
}

###############
# Directories #
###############
directory node['app']['directories']['runtime'] do
  owner node['ssh']['user']
  mode '0755'
  recursive true
end

directory node['app']['directories']['configuration'] do
  owner node['ssh']['user']
  mode '0770'
  recursive true
end

################
# Install Cron #
################
include_recipe 'cron'

##############
# Deployment #
##############
# retrieve configuration details from data bag
apps = node['deploy']['app'][node.chef_environment]

apps.each do |app|
  
  ###############
  # Directories #
  ###############
  directory "/var/uploads/#{app['subdomain']}.#{app['domain']}" do
    recursive true
    owner node['app']['user']
    group 'www-data'
    mode '0775'
  end
  
  directory "/var/log/#{app['subdomain']}.#{app['domain']}" do
    recursive true
    owner node['app']['user']
    group 'www-data'
    mode '0770'
  end
  
  #############
  # variables #
  #############
  env_vars['PYTHON_PORT'] = app['port']
  subdomain = app['subdomain']
  domain = app['domain']
  port = app['port']
  force_ssl = app['ssl']
  nginx_template = app['nginx_config_template']
  
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
  uwsgi_config = app['config']['uwsgi']
  programs = app['programs']
  
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
  
  python_virtualenv "/var/#{domain}/#{subdomain}/.venv" do
    python '3' # for the python runtime use the "system" version of python
    user 'www-data'
    group 'www-data'
  end
  
  # install pip packages from requirements.txt
  pip_requirements "/var/#{domain}/#{subdomain}/requirements.txt" do
    virtualenv "/var/#{domain}/#{subdomain}/.venv"
    user 'www-data'
    group 'www-data'
  end
  
  # create uwsgi ini directory
  directory "/var/#{domain}/#{subdomain}/.uwsgi" do
    user 'www-data'
    group 'www-data'
    mode '0755'
    action :create
  end
  
  file "/var/#{domain}/#{subdomain}/.uwsgi/#{node['uwsgi']['reload']['file']}" do
    user 'www-data'
    group 'www-data'
    mode '0644'
  end
  
  # app ini file
  uwsgi_config['socket'] = "/var/run/uwsgi/uwsgi-#{subdomain}.#{domain}.sock"
  uwsgi_config['chown-socket'] = "www-data:www-data"
  uwsgi_config['chmod-socket'] = 660
  uwsgi_config['touch-reload'] = "/var/#{domain}/#{subdomain}/.uwsgi/#{node['uwsgi']['reload']['file']}"
  uwsgi_config['uid'] = 'www-data'
  uwsgi_config['gid'] = 'www-data'
  uwsgi_config['virtualenv'] = "/var/#{domain}/#{subdomain}/.venv"
  uwsgi_config['chdir'] = "/var/#{domain}/#{subdomain}"
  
  template "/var/#{domain}/#{subdomain}/.uwsgi/app.ini" do
    source "app.ini.erb"
    owner 'www-data'
    group 'www-data'
    mode '0755'
    variables(
      :name => 'uwsgi',
      :config => uwsgi_config
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
    program_config['user'] = node['app']['user']
    program_config['environment'] = env_vars.keys.map{|key| "#{key}=#{env_vars[key]}"}.join(",")
    
    template "/etc/supervisor/conf.d/#{program_name}.conf" do
      source "supervisor_program.conf.erb"
      variables(
        :program_name => program_name,
        :program_config => program_config
      )
    end 
    
    # create socket directories
    directory "/var/run/#{program_name}" do
      user 'www-data'
      group 'www-data'
      mode '0755'
      action :create
    end
    
    # create configuration for creation, deletion and cleaning of volatile and temporary files
    file "/usr/lib/tmpfiles.d/#{program_name}.conf" do
      content "d /var/run/#{program_name} 0775 www-data www-data"
      mode '0644'
      owner 'root'
      group 'root'
    end
    
    # create log directories
    directory "/var/log/#{program_name}" do
      user 'supervisor'
      group 'www-data'
      mode '0770'
      action :create
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
      :ssl_directory => node['app']['directories']['ssl'],
      :uwsgi_socket => "/var/run/uwsgi/uwsgi-#{subdomain}.#{domain}.sock"
    )
  end
  
  # setup cron jobs
  app['cron_jobs'].each do |cron_job|
    cron_d cron_job['name'] do
      minute cron_job['minute']
      hour cron_job['hour']
      day cron_job['day']
      month cron_job['month']
      weekday cron_job['weekday']
      mailto cron_job['mailto']
      command cron_job['command']
    end
  end
  
  if app['jupyter']
    # create directory for shell script
    directory "/srv/jupyter/#{app['subdomain']}.#{app['domain']}" do
      mode '0755'
      recursive true
    end
    
    node['deploy']['jupyter'][node.chef_environment].each do |jupyter|
      # create a shell script that generates *.html files from *.ipynb files
      template "/srv/jupyter/#{app['subdomain']}.#{app['domain']}/notebook-html-#{jupyter['subdomain']}.#{jupyter['domain']}.sh" do
        source "jupyter_notebook_html.sh.erb"
          variables(
            :subdomain => subdomain,
            :domain => domain,
            :jupyter_subdomain => jupyter['subdomain'],
            :jupyter_domain => jupyter['subdomain']
          )
      end # end template "/srv/jupyter/#{app['subdomain']}.#{app['domain']}/notebook-html-#{jupyter['subdomain']}.#{jupyter['domain']}.sh" do
      
      # start a cronjob to call that shell script
      cron_d "move_jupyter_notebooks" do
        predefined_value '@midnight'
        command "bash /srv/jupyter/#{app['subdomain']}.#{app['domain']}/notebook-html-#{jupyter['subdomain']}.#{jupyter['domain']}.sh"
      end # cron_d "move_jupyter_notebooks" do
    end # node['deploy']['jupyter'][node.chef_environment].each do |jupyter|
  end # if app['jupyter']
end