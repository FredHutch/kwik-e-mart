#
# Cookbook Name:: ci-btb
# Recipe:: default
#
# Copyright (c) 2016 The Authors, All Rights Reserved.
#
include_recipe 'apt::default'

apt_repository 'octopus_fhcrc' do
    uri             'http://octopus.fhcrc.org/fhcrc/ubuntu'
    distribution    "#{node['lsb']['codename']}"
    key             'http://octopus.fhcrc.org/fhcrc/ubuntu/scicomp.gpg.key'
    components      [ 'main' ]
    arch            'amd64'
    deb_src         false
end

include_recipe 'apt-chef::stable'

package [ 'chefdk', 'git' ] do
    action :install
end

gem_package 'knife-supermarket' do
    gem_binary('/opt/chefdk/embedded/bin/gem')
    options('--no-user-install')
end
