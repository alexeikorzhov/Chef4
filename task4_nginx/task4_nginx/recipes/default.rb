#
# Cookbook:: task4_nginx
# Recipe:: default
#
# Copyright:: 2017, The Authors, All Rights Reserved.

package "nginx" do
  action :install
end

service 'nginx' do  	
  action [:enable, :start]  	
  supports :reload => true
end

lb 'change_lb' do
  role 'apache_server'
  action :attach
  notifies :restart, 'service[nginx]'
end

lb 'change_lb' do
  role 'jboss_server'
  action :attach
  notifies :restart, 'service[nginx]'
end
