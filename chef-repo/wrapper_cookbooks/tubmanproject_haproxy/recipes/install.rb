#
# Cookbook:: tubmanproject_haproxy
# Recipe:: install
#
# Copyright:: 2017, Tyrone Saunders, All Rights Reserved.

haproxy_install 'package'

haproxy_config_defaults 'default' do
  balance node['haproxy']['balance_algorithm']
end
