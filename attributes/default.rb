#
# Cookbook Name:: scigrad
# Recipe:: default
#
# Copyright (C) 2014, Western University
#
# All rights reserved - Do Not Redistribute
#

node.set['mysql']['server_root_password'] = ''

default['scigrad']['deploy_user'] = 'vagrant'
default['scigrad']['web_server_group'] = 'www-data'
default['scigrad']['database']['host'] = 'localhost'
default['scigrad']['database']['name'] = 'scigrad'
default['scigrad']['database']['test_name'] = 'scigrad_test'
default['scigrad']['database']['user'] = 'scigraduser'
default['scigrad']['database']['password'] = 'sc13nc3F+w!'

