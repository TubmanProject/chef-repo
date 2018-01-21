#
# Cookbook:: tubmanproject_rabbitmq
# Recipe:: cluster
#
# Copyright:: 2017, Tyrone Saunders, All Rights Reserved.

Chef::Recipe.send(:include, OpenSSLCookbook::RandomPassword)

####################
# Data Bag Secrets #
####################
apps = node['secrets']['rabbitmq'][node.chef_environment]['applications']

####################
# Install RabbitMQ #
####################
node.override['rabbitmq']['clustering']['enable'] = true
node.override['rabbitmq']['erlang_cookie'] = random_password(length: 128)
# install rabbitmq
include_recipe "rabbitmq::cluster"

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
#rabbitmq_user "guest" do
#  action :delete
#end

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
