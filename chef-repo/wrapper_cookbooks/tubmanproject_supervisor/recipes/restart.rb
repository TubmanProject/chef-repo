#
# Cookbook:: tubmanproject_supervisor
# Recipe:: restart
#
# Copyright:: 2017, Tyrone Saunders, All Rights Reserved.

# inform supervisor of configuration changes and enact changes
bash "supervisor config changes" do
  live_stream true
  code <<-EOH
    supervisorctl reread
    supervisorctl update
    supervisorctl restart all
    EOH
end
