# Validating ssl certificate is de-facto necessary since chef >= 11.12.0
# http://stackoverflow.com/questions/22991561/chef-solo-ssl-warning-when-provisioning
Chef::Config.ssl_verify_mode = :verify_peer

# enable local-mode to restore behavior of vagrant <= 1.7.2 chef-zero provisioner
local_mode true

# Move lockfile out of the (potentially shared) file_cache_path;
# see https://github.com/fgrehm/vagrant-cachier/issues/28
lockfile '/var/run/chef-client-running.pid'

# Set chef proxies from ENV because vagrant-proxyconf does not detect chef provisionners
# in multi-vm setups; see https://github.com/tmatilai/vagrant-proxyconf/issues/101
http_proxy ENV['http_proxy'] unless String(ENV['http_proxy']).empty?
https_proxy ENV['https_proxy'] unless String(ENV['https_proxy']).empty?
ftp_proxy ENV['ftp_proxy'] unless String(ENV['ftp_proxy']).empty?
no_proxy ENV['no_proxy'] unless String(ENV['no_proxy']).empty?