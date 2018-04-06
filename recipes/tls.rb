#
# Cookbook Name:: loggly
# Recipe:: tls
#
# Copyright (C) 2014 Matt Veitas
# 
# All rights reserved - Do Not Redistribute
#

package 'rsyslog-gnutls' do
  action :install
end

cert_path = node['loggly']['tls']['cert_path']
cert_name = 'loggly.com.crt'

directory cert_path do
  owner 'root'
  group 'syslog'
  mode 0755
  action :create
  recursive true
end

remote_file 'download loggly.com cert' do
  owner 'root'
  group 'root'
  mode 0644
  path "#{cert_path}/#{cert_name}"
  source node['loggly']['tls']['cert_url']
  checksum node['loggly']['tls']['cert_checksum']

  not_if { ::File.exists?("#{cert_path}/#{cert_name}") and not node[:loggly][:force_update] }
end

