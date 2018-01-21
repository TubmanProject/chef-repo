#
# Cookbook:: tubmanproject_mongodb
# Recipe:: install
#
# Copyright:: 2017, Tyrone Saunders, All Rights Reserved.

# Import the public key used by the package management system.
bash 'Import MongoDB public GPG Key' do
  code 'apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 2930ADAE8CAF5059EE73BB4B58712A2291FA4AD5'
end

# Create list file for mongodb
bash 'Create list file for MongoDB' do
  code 'echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/3.6 multiverse" | tee /etc/apt/sources.list.d/mongodb-org-3.6.list'
end

# Reload the local package database
bash 'Reload local package database' do
  code 'apt-get update'
end

include_recipe 'sc-mongodb::default'
