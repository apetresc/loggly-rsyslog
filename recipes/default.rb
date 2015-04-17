#
# Cookbook Name:: loggly
# Recipe:: default
#
# Copyright (C) 2014 Matt Veitas
#
# All rights reserved - Do Not Redistribute
#

if node['loggly']['token']['value']
  loggly_token = node['loggly']['token']['value']
else
  databag = node['loggly']['token']['databag']
  databag_item = node['loggly']['token']['databag_item']

  loggly_token = Chef::EncryptedDataBagItem.load(databag, databag_item)['token']
  raise "No token was found in databag item: #{databag}/#{databag_item}" if loggly_token.nil?
end

include_recipe "rsyslog::default"

include_recipe "loggly-rsyslog::tls" if node['loggly']['tls']['enabled']

template node['loggly']['rsyslog']['conf'] do
  source 'rsyslog-loggly.conf.erb'
  owner 'root'
  group 'root'
  mode 0644
  variables({
    :monitor_files => !node['loggly']['log_files'].empty? || !node['loggly']['log_dirs'].empty?,
    :tags => node['loggly']['tags'].nil? || node['loggly']['tags'].empty? ? '' : "tag=\\\"#{node['loggly']['tags'].join("\\\" tag=\\\"")}\\\"",
    :token => loggly_token
  })
  notifies :restart, "service[rsyslog]", :immediate
end
