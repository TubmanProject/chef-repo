#
# Cookbook:: tubmanproject_supervisor
# Recipe:: install
#
# Copyright:: 2017, Tyrone Saunders, All Rights Reserved.

######################
# Install supervisor #
######################
# install supvervisor
python_package 'supervisor' do
  python '2'
end

# create supervisor user group
users_manage 'supervisor'

# add the www-data user to the supervisor group
group "supervisor" do
  action :modify
  append true
  members [node['app']['user'], node['ssh']['user']]
end

# create directories
directories = ['/etc/supervisor/conf.d', '/var/log/supervisor']
directories.each do |path|
  directory path do
    recursive true
    owner 'supervisor'
    group node['app']['user']
    mode '0750'
  end
end

# create the main supervisor configuration file
template "/etc/supervisor/supervisord.conf" do
  source "supervisord.conf.erb"
  variables(
    :includes => ["files=/etc/supervisor/conf.d/*.conf"]
  )
end

supervisor_service_file = {
  'Unit' => {
    'Description' => 'Supervisor process control system',
    'Documentation' => 'http://supervisord.org',
    'After' => 'network.target'
  },
  'Service' => {
    'ExecStart' => "/usr/local/bin/supervisord -n -c /etc/supervisor/supervisord.conf",
    'ExecStop' => "/usr/local/bin/supervisorctl $OPTIONS shutdown",
    'ExecReload' => "/usr/local/bin/supervisorctl -c /etc/supervisor/supervisord.conf $OPTIONS reload",
    'KillMode' => 'process',
    'Restart' => 'on-failure',
    'RestartSec' => '50s'
  },
  'Install' => {
    'WantedBy' => 'multi-user.target'
  }
}

# add supervisor to systemd services for Ubuntu 16.04
systemd_unit "supervisor.service" do
  enabled true
  active true
  content supervisor_service_file
  action :create
end

# start and enable the supervisor service
service "supervisor" do
  action [:enable, :start]
  provider Chef::Provider::Service::Systemd
end
