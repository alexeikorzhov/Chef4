resource_name :lb
property :role,  String, default: 'test'

action :attach do

template "/etc/nginx/conf.d/backend_srv.conf" do
  source "backend_srv.conf.erb"
end

template "/etc/nginx/nginx.conf" do
  source "nginx.conf.erb"
end

user 'nginx' do
  comment 'A new user for nginx server'
  shell '/sbin/nologin'
  system true
  action [:create, :lock]
end

group 'nginx' do
  action :create
  members 'nginx'
  append true
end

bash "Creating directory for /nginx/lb" do
  code <<-SHELL
  mkdir /etc/nginx/lb
  chown nginx:nginx -R /etc/nginx/lb
  chmod 775 -R /etc/nginx/lb
  SHELL
end

lb_nodes = search(:node, "role:#{role}")

lb_nodes.each do |lb_node|
  file "/etc/nginx/lb/#{lb_node['network']['interfaces']['enp0s8']['routes'][0]['src']}.lb" do
    content "server #{lb_node['network']['interfaces']['enp0s8']['routes'][0]['src']};"
    action :create
  end
end
end

action :detach do

lb_nodes = search(:node, "role:#{role}")

lb_nodes.each do |lb_node|
  file "/etc/nginx/lb/#{lb_node['network']['interfaces']['enp0s8']['routes'][0]['src']}.lb" do
    content "server #{lb_node['network']['interfaces']['enp0s8']['routes'][0]['src']};"
    action :delete
  end
end
end
