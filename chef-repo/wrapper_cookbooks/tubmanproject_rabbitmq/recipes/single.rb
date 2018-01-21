#
# Cookbook:: tubmanproject_rabbitmq
# Recipe:: single
#
# Copyright:: 2017, Tyrone Saunders, All Rights Reserved.

####################
# Data Bag Secrets #
####################
apps = node['secrets']['rabbitmq'][node.chef_environment]['applications']
rabbitmq_clusters = node['secrets']['rabbitmq'][node.chef_environment]['cluster_nodes']
rabbitmq_node = rabbitmq_clusters.first

####################
# Install RabbitMQ #
####################
# rabbitmq_host = "#{node['secrets']['rabbitmq'][node.chef_environment]['hostname']}.#{node['secrets']['rabbitmq'][node.chef_environment]['domain']}"
node.override['rabbitmq']['clustering']['enable'] = false
node.override['rabbitmq']['nodename'] = "#{rabbitmq_node['nodename']}@#{node['hostname']}"
node.override['rabbitmq']['port'] = rabbitmq_node['port']

# install rabbitmq
include_recipe "rabbitmq"

##############################
# Start the rabbitmq service #
##############################
service node['rabbitmq']['service_name'] do
  action [:enable, :start]
end

####################################
# configure applications and users #
####################################

# delete the default "guest" user
# rabbitmq_user "guest" do
#  action :delete
# end

apps.each do |app|
  ##########
  # vHosts #
  ##########
  # create a separate vhost for each application that connects
  # from the applications (python app in this case) match the subdomain to the vhost
  rabbitmq_vhost app['vhost'] do
    action :add
  end

  #########
  # users #
  #########
  # create separate user (per application) with admin permissions and password
  app['users'].each do |user|
    rabbitmq_user user['username'] do
      password user['password']
      action :add
    end

    rabbitmq_user user['username'] do
      vhost ["/", "#{app['vhost']}"]
      permissions "#{user['permissions']['conf']} #{user['permissions']['read']} #{user['permissions']['write']}"
      action :set_permissions
    end
  end
end

################################
# Restart the rabbitmq service #
################################
service node['rabbitmq']['service_name'] do
  action [:restart]
end
