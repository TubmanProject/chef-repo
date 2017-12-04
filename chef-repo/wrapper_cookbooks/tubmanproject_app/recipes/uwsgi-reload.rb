#
# Cookbook:: tubmanproject_app
# Recipe:: uwsgi-reload
#
# Copyright:: 2017, Tyrone Saunders, All Rights Reserved.

# install netcat which is called in the shell script
package "netcat" do
  action :upgrade
end

# firewall
execute "reload port #{node['uwsgi']['reload']['port']} firewall" do
  command "sudo ufw allow #{node['uwsgi']['reload']['port']}"
end

apps = node['deploy']['app'][node.chef_environment]
apps.each do |app|
  # create the reload file
  file "/var/#{app['domain']}/#{app['subdomain']}/.uwsgi/#{node['uwsgi']['reload']['file']}"
  
  # create the shell script for host machine
  template "/var/#{app['domain']}/#{app['subdomain']}/.uwsgi/fswatch-client.sh" do
    source "fswatch-client.sh.erb"
    variables(
      :project_path => "#{node['host_machine']['project_path']}/#{app['subdomain']}",
      :port => node['uwsgi']['reload']['port']
    )
  end
  
  # create the shell script for server
  template "/var/#{app['domain']}/#{app['subdomain']}/.uwsgi/uwsgi-reload.sh" do
    source "uwsgi-reload.sh.erb"
    variables(
      :port => node['uwsgi']['reload']['port'],
      :file => "/var/#{app['domain']}/#{app['subdomain']}/.uwsgi/#{node['uwsgi']['reload']['file']}"
    )
  end
  
  # write the systemd service file
  service_file = {
    'Unit' => {
      'Description' => "uWSGI reload service for #{app['subdomain']}.#{app['domain']}",
      'Documentation' => 'http://chase-seibert.github.io/blog/2014/03/30/uwsgi-python-reload.html',
      'After' => 'network.target'
    },
    'Service' => {
      'Type' => "simple",
      'ExecStart' => "/var/#{app['domain']}/#{app['subdomain']}/.uwsgi/uwsgi-reload.sh",
      'Restart' => 'on-failure'
    },
    'Install' => {
      'WantedBy' => 'multi-user.target' 
    }
  }
  
  # add uwsgi-reload to systemd services for Ubuntu 16.04
  systemd_unit "uwsgi-reload-#{app['subdomain']}.#{app['domain']}.service" do
    enabled true
    active true
    content service_file
    action [:create, :enable]
  end
  
  # start the uwsgi-reload service
  service "uwsgi-reload-#{app['subdomain']}.#{app['domain']}" do
    action [:enable, :start]
  end  
end
