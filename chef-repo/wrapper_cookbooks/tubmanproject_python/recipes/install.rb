#
# Cookbook:: tubmanproject_python
# Recipe:: install
#
# Copyright:: 2017, Tyrone Saunders, All Rights Reserved.

#########################
# Update Apt Repository #
#########################
apt_repository 'jonathonf_ppa' do
  uri 'ppa:jonathonf/python-3.6'
end

#######################################
# Install Python, pip, and virtualenv #
#######################################
python_runtime '2' do
  version '2.7'
  options(
    :provider => 'system',
    :package_name => 'python2.7',
    :dev_package => true
  )
  action :install
end

python_runtime '3' do
  version '3.6'
  options(
    :provider => 'system',
    :package_name => 'python3.6',
    :dev_package => true
  )
  action :install
end