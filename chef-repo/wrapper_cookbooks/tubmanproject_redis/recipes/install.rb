# Cookbook:: mintyross_redis
# Recipe:: install
#
# Copyright:: 2017, Tyrone Saunders, All Rights Reserved.

#################
# Install Redis #
#################
redisio_install 'redis-installation' do
  version node['redisio']['version']
  download_url "http://download.redis.io/releases/redis-#{node['redisio']['version']}.tar.gz"
  safe_install false
end

###################
# Configure Redis #
###################
redisio_configure 'redis-server-configuration' do
  version node['redisio']['version']
  base_piddir node['redisio']['base_piddir']
  default_settings node['redisio']['default_settings']
  servers node['redisio']['servers'].values
end

# start and enable the redis servers
node['redisio']['servers'].each_key do |redis_server_name|
  service "redis@#{redis_server_name}" do
    action %i[enable start]
  end
end
