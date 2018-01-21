name 'tubmanproject_redis'
maintainer 'Tyrone Saunders'
maintainer_email ''
license 'All Rights Reserved'
description 'Installs/Configures tubmanproject_redis'
long_description 'Installs/Configures tubmanproject_redis'
version '0.1.0'
chef_version '>= 12.1' if respond_to?(:chef_version)

# The `issues_url` points to the location where issues for this cookbook are
# tracked.  A `View Issues` link will be displayed on this cookbook's page when
# uploaded to a Supermarket.
#
# issues_url 'https://github.com/tubmanproject/chef-repo/issues'

# The `source_url` points to the development reposiory for this cookbook.  A
# `View Source` link will be displayed on this cookbook's page when uploaded to
# a Supermarket.
#
# source_url 'https://github.com/tubmanproject/chef-repo/wrapper_cookbooks/tubmanproject_redis'

depends 'redisio',           '~> 2.6.1'
depends 'openssl',           '~> 7.1.0'

depends 'tubmanproject_base'
depends 'tubmanproject_github'
depends 'tubmanproject_nginx'
depends 'tubmanproject_nodejs'
