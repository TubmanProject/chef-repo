# Cookbook Name:: tubmanproject_nginx
# Attribute:: default
#
# Copyright 2017, Tyrone Saunders. All Rights Reserved.

node.override['nginx']['install_method'] = 'source'
node.override['nginx']['version'] = '1.12.2'
node.override['nginx']['default_site_enabled'] = false
node.override['nginx']['server_names_hash_bucket_size'] = 128
node.override['nginx']['source']['modules'] = [
  'nginx::ipv6',
  'nginx::http_echo_module',
  'nginx::http_auth_request_module',
  'nginx::http_geoip_module',
  'nginx::http_mp4_module',
  'nginx::http_realip_module',
  'nginx::http_gzip_static_module',
  'nginx::http_ssl_module',
  'nginx::upload_progress_module',
  'nginx::openssl_source'
]
node.override['nginx']['configure_flags'] = [
  '--with-stream'
]
