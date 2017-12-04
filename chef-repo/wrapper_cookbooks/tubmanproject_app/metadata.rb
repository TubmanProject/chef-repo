name 'tubmanproject_app'
maintainer 'Tyrone Saunders'
maintainer_email ''
license 'All Rights Reserved'
description 'Installs/Configures tubmanproject_app'
long_description 'Installs/Configures tubmanproject_app'
version '0.1.0'
chef_version '>= 12.1' if respond_to?(:chef_version)

# The `issues_url` points to the location where issues for this cookbook are
# tracked.  A `View Issues` link will be displayed on this cookbook's page when
# uploaded to a Supermarket.
#
# issues_url 'https://github.com/tubmanproject/chef-repo/issues'

# The `source_url` points to the development repository for this cookbook.  A
# `View Source` link will be displayed on this cookbook's page when uploaded to
# a Supermarket.
#
# source_url 'https://github.com/tubmanproject/chef-repo/chef-repo/wrapper_cookbooks/tubmanproject_app'

depends 'users',             '~> 5.2.1'
depends 'openssl',           '~> 7.1.0'
depends 'nginx',             '~> 7.0.0'
depends 'poise-python',      '~> 1.6.0'
depends 'nodejs',            '~> 4.0.0'
depends 'cron',              '~> 4.2.0'
depends 'acme',               '~> 3.1.0'

depends 'tubmanproject_base'
depends 'tubmanproject_github'
depends 'tubmanproject_openssl'
depends 'tubmanproject_nginx'
depends 'tubmanproject_nodejs'
depends 'tubmanproject_python'
depends 'tubmanproject_supervisor'
