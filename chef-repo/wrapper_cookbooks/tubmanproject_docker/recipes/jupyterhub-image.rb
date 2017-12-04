#
# Cookbook:: tubmanproject_docker
# Recipe:: jupyterhub-image
#
# Copyright:: 2017, Tyrone Saunders, All Rights Reserved.

jupyterhub_apps = node['deploy']['jupyterhub'][node.chef_environment]

jupyterhub_apps.each do |jupyterhub_app|
  
  # create directory for dockerfile storage
  directory "/etc/docker/dockerfile/#{jupyterhub_app['subdomain']}.#{jupyterhub_app['domain']}" do
    recursive true
    mode '0755'
    not_if {::Dir.exist?("/etc/docker/dockerfile/#{jupyterhub_app['subdomain']}.#{jupyterhub_app['domain']}")}
  end
  
  # pull the base docker image
  docker_image jupyterhub_app['config']['jupyterhub']['docker']['image'] do
    tag jupyterhub_app['config']['jupyterhub']['docker']['tag']
    action :pull
  end
  
  if jupyterhub_app['config']['jupyterhub']['docker']['build'] 
    # create a docker file
    template "/etc/docker/dockerfile/#{jupyterhub_app['subdomain']}.#{jupyterhub_app['domain']}/Dockerfile" do
      source 'dockerfile.erb'
      variables(
        :from => "#{jupyterhub_app['config']['jupyterhub']['docker']['image']}:#{jupyterhub_app['config']['jupyterhub']['docker']['tag']}",
        :run => jupyterhub_app['config']['jupyterhub']['docker']['run'] || nil
      )
    end
    
    # build a docker image
    docker_image "jupyterhub-image/#{jupyterhub_app['subdomain']}.#{jupyterhub_app['domain']}" do
      source "/etc/docker/dockerfile/#{jupyterhub_app['subdomain']}.#{jupyterhub_app['domain']}/Dockerfile"
      action :build_if_missing
    end
  end # if jupyterhub_app['config']['jupyterhub']['docker']['build'] 
end # jupyterhub_apps.each do |jupyterhub_app|
