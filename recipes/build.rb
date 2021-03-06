#
# Cookbook Name:: dd-agent-osx-build-box
# Recipe:: build
#
# Copyright 2015, Datadog Inc.
#
# All rights reserved - Do Not Redistribute
#

# required by the omnibus_build resource
include_recipe 'chef-sugar::default'

dd_agent_omnibus_dir = "#{build_user_home}/dd-agent-omnibus"
# let's clean bundle state
# first Gemfile.lock
file "#{dd_agent_omnibus_dir}/Gemfile.lock" do
  action :delete
end

# then .bundle directory
directory "#{dd_agent_omnibus_dir}/.bundle" do
  action :delete
  recursive true
end

# delete Gohai cache (otherwise build fails)
# DELETE ME WHEN CENTOS 5 IS EOL
directory 'C:\omnibus-ruby\cache\src' do
  action :delete
  recursive true
end

# Sync the repositories
git dd_agent_omnibus_dir do
  repository 'https://github.com/DataDog/dd-agent-omnibus'
  revision node['dd-agent-builder']['dd-agent-omnibus_branch']
  action :sync
end

omnibus_build 'datadog-agent' do
  project_dir dd_agent_omnibus_dir
  log_level :info
  live_stream true
  install_dir node['dd-agent-builder']['install_dir']
  environment 'AGENT_BRANCH' => node['dd-agent-builder']['dd-agent_branch'],
              'OMNIBUS_RUBY_BRANCH' => node['dd-agent-builder']['omnibus-ruby_branch'],
              'OMNIBUS_SOFTWARE_BRANCH' => node['dd-agent-builder']['omnibus-software_branch'],
              'INTEGRATIONS_CORE_BRANCH' => node['dd-agent-builder']['integrations-core_branch'],
              'JMX_VERSION' => node['dd-agent-builder']['jmx-fetch_version']
  config_overrides 'append_timestamp' => false
end
