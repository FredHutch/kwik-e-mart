#
# Cookbook Name:: kwik-e-mart
# Recipe:: users
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

user node['kwik-e-mart']['user']['username'] do
    supports :manage_home => true
    comment 'Build Automation User'
    home node['kwik-e-mart']['user']['unix_home']
    shell '/bin/bash'
end

directory "#{node['kwik-e-mart']['user']['unix_home']}/.chef" do
    owner node['kwik-e-mart']['user']['username']
    mode '0700'
end

template "#{node['kwik-e-mart']['user']['unix_home']}/.chef/knife.rb" do
    source 'knife.rb.erb'
    owner node['kwik-e-mart']['user']['username']
    mode '0644'
    variables({
        :server_url => node['kwik-e-mart']['knife-config']['chef_server_url'],
        :supermarket_url => node['kwik-e-mart']['knife-config']['supermarket_site'],
        :chef_server_username => node['kwik-e-mart']['knife-config']['chef_server_username']
    })
end

execute 'server_ssl_certs' do
    command "knife ssl fetch #{node['kwik-e-mart']['knife-config']['supermarket_site']} --config /var/spool/btb/.chef/knife.rb --verbose"
    live_stream true
    user node['kwik-e-mart']['user']['username']
    creates "#{node['kwik-e-mart']['user']['unix_home']}/.chef/trusted_certs"
end

