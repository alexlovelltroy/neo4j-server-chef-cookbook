#
# Cookbook Name:: neo4j-server
# Recipe:: configure
# Copyright 2012, Michael S. Klishin <michaelklishin@me.com>
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
#
service "neo4j" do
  supports :start => true, :stop => true, :restart => true
  action :nothing
  subscribes :restart, 'template[/etc/init.d/neo4j]'
end

# 6. Install config files
template "#{node.neo4j.server.conf_dir}/neo4j-server.properties" do
  source "neo4j-server.properties.erb"
  owner node.neo4j.server.user
  mode  0644
  notifies :restart, 'service[neo4j]'
end

template "#{node.neo4j.server.conf_dir}/neo4j-wrapper.conf" do
  source "neo4j-wrapper.conf.erb"
  owner node.neo4j.server.user
  mode  0644
  notifies :restart, 'service[neo4j]'
end

template "#{node.neo4j.server.conf_dir}/neo4j.properties" do
  source "neo4j.properties.erb"
  owner node.neo4j.server.user
  mode 0644
  notifies :restart, 'service[neo4j]'
end

# 7. Know Your Limits
template "/etc/security/limits.d/#{node.neo4j.server.user}.conf" do
  source "neo4j-limits.conf.erb"
  owner node.neo4j.server.user
  mode  0644
  notifies :restart, 'service[neo4j]'
end

ruby_block "make sure pam_limits.so is required" do
  block do
    fe = Chef::Util::FileEdit.new("/etc/pam.d/su")
    fe.search_file_replace_line(/# session    required   pam_limits.so/, "session    required   pam_limits.so")
    fe.write_file
  end
  notifies :restart, 'service[neo4j]'
end
