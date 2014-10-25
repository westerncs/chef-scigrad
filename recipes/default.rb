#
# Cookbook Name:: scigrad
# Recipe:: default
#
# Copyright (C) 2014, Western University
#
# All rights reserved - Do Not Redistribute
#

%w[language-pack-en apache2 libapache2-mod-php5 php5-cli tmux vim curl php5-mysql php5-mcrypt].each do |pkg|
  package pkg do
    action :install
  end
end

include_recipe "mysql::server"
include_recipe "database::mysql"

mysql_connection_info = {
  :host     => node['scigrad']['database']['host'],
  :username => 'root',
  :password => node['mysql']['server_root_password']
}

mysql_database node['scigrad']['database']['name'] do
  connection mysql_connection_info
  action     :create
end

mysql_database node['scigrad']['database']['test_name'] do
  connection mysql_connection_info
  action     :create
end

mysql_database_user node['scigrad']['database']['user'] do
  connection mysql_connection_info
  password   node['scigrad']['database']['password']
  host       node['scigrad']['database']['host']
  action     :create
end

mysql_database_user node['scigrad']['database']['user'] do
  connection    mysql_connection_info
  database_name node['scigrad']['database']['name']
  host          node['scigrad']['database']['host']
  privileges    [:all]
  action        :grant
end

mysql_database_user node['scigrad']['database']['user'] do
  connection    mysql_connection_info
  database_name node['scigrad']['database']['test_name']
  host          node['scigrad']['database']['host']
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

bash 'enable mod_rewrite' do
  user 'root'
  code 'a2enmod rewrite'
  action :run
  notifies :restart, 'service[apache2]'
end

cookbook_file '/etc/apache2/sites-enabled/scigrad.conf' do
  source 'scigrad.conf'
  owner  'root'
  group  'root'
  mode   '0644' 
  action :create
  notifies :restart, 'service[apache2]'
end

################################################################################
# PHP configuration                                                            #
################################################################################

bash 'install composer' do
  user 'root'
  code <<-EOH
curl -sS https://getcomposer.org/installer | php
mv composer.phar /usr/local/bin/composer
  EOH
  action :run
  not_if { File.exist?('/usr/local/bin/composer') }
end

bash 'enable mcrypt' do
  user 'root'
  code 'php5enmod mcrypt'
  action :run
end

################################################################################
# Web app configuration                                                        #
################################################################################

directory '/var/www/scigrad' do
  owner  node['scigrad']['deploy_user']
  group  node['scigrad']['deploy_user']
  mode   '0755'
  action :create
end

directory '/etc/scigrad' do
  owner node['scigrad']['deploy_user']
  group node['scigrad']['web_server_group']
  mode  0750
  action :create
end

template '/etc/scigrad/database.php' do

  source 'database.php.erb'
  owner  node['scigrad']['deploy_user']
  group  node['scigrad']['web_server_group']
  mode   0640
  variables({
    host: node['scigrad']['database']['host'],
    db_name: node['scigrad']['database']['name'],
    test_db_name: node['scigrad']['database']['test_name'],
    user: node['scigrad']['database']['user'],
    password: node['scigrad']['database']['password']
  })

end

link '/var/www/scigrad/Config/database.php' do
  to '/etc/scigrad/database.php'
end

bash 'make tmp writable' do
  user 'root'
  code "chown -R #{node['scigrad']['web_server_group']} /var/www/scigrad/tmp"
  action :run
end

