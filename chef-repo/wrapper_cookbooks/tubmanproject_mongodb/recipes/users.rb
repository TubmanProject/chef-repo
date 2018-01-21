#
# Cookbook:: tubmanproject_mongodb
# Recipe:: users
#
# Copyright:: 2017, Tyrone Saunders, All Rights Reserved.

include_recipe 'sc-mongodb::user_management'

# create mongodb users
node['secrets']['mongodb'][node.chef_environment]['users'].each do |user|
  mongodb_user user['username'] do
    password user['password']
    roles user['roles']
    database user['database']
    connection node['mongodb']
    action :add
  end
end
