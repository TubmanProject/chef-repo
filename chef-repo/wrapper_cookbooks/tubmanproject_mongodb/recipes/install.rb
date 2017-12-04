#
# Cookbook:: tubmanproject_mongodb
# Recipe:: install
#
# Copyright:: 2017, Tyrone Saunders, All Rights Reserved.

include_recipe "sc-mongodb::default"

# create mongodb users
node['secrets']['mongodb'][node.chef_environment]['users'].each do |user|
  mongodb_user user['username'] do
    password user['password']
    roles user['roles']
    database user['database']
    action :add
  end
end


