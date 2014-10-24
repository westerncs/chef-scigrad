#
# Cookbook Name:: scigrad
# Recipe:: default
#
# Copyright (C) 2014, Western University
#
# All rights reserved - Do Not Redistribute
#

%w[language-pack-en apache2 libapache2-mod-php5 php5-cli tmux vim].each do |pkg|
  package pkg do
    action :install
  end
end

include_recipe "mysql::server"
include_recipe "database::mysql"

mysql_connection_info = {
  :host     => 'localhost',
  :username => 'root',
  :password => node['mysql']['server_root_password']
}

mysql_database 'scigrad' do
  connection mysql_connection_info
  action     :create
end

mysql_database 'scigrad_test' do
  connection mysql_connection_info
  action     :create
end

mysql_database_user 'scigraduser' do
  connection mysql_connection_info
  password   'sc13nc3F+w!'
  host       'localhost'
  action     :create
end

mysql_database_user 'scigraduser' do
  connection    mysql_connection_info
  database_name 'scigrad'
  host          'localhost'
  privileges    [:all]
  action        :grant
end

mysql_database_user 'scigraduser' do
  connection    mysql_connection_info
  database_name 'scigrad_test'
  host          'localhost'
  privileges    [:all]
  action        :grant
end


################################################################################
# Apache configuration                                                         #
################################################################################

service 'apache2' do
  supports [:start, :stop, :restart, :enable]
  action :enable
end

file '/etc/apache2/sites-enabled/000-default.conf' do
  action :delete
end

cookbook_file '/etc/apache2/sites-enabled/scigrad.conf' do
  source 'scigrad.conf'
  owner  'root'
  group  'root'
  mode   '0644' 
  action :create
  notifies :restart, 'service[apache2]', :immediately
end

