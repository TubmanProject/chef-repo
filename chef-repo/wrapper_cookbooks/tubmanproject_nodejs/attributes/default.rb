# Cookbook Name:: tubmanproject_nodejs
# Attribute:: default
#
# Copyright 2017, Tyrone Saunders. All Rights Reserved.

# override cookbook attributes
node.override['nodejs']['version'] = '8.9.1'
node.override['nodejs']['source']['checksum'] = '32491b7fcc4696b2cdead45c47e52ad16bbed8f78885d32e873952fee0f971e1'
node.override['nodejs']['repo'] = 'https://deb.nodesource.com/node_8.x'