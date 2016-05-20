#
# Cookbook Name:: kwik-e-mart
# Recipe:: upload
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

#execute "list_cookbooks" do
#    command "knife supermarket show congenial-happiness 0.1.33 --config /var/spool/btb/.chef/knife.rb --verbose"
#    live_stream true
#    user 'btb'
#end
#execute "list_cookbooks" do
#    command "knife supermarket show congenial-happiness 0.1.33 #{knife_options}"
#    live_stream true
#    user node['kwik-e-mart']['user']['username']
#end
#execute "whoami" do
#    command "whoami"
#    live_stream true
#    user 'btb'
#end

# This cookbook goes through all of the cookbooks in the configured
# source directory- these should be vendored cookbooks delivered from
# upstream (i.e. CircleCI)
#
# For each cookbook, upload first to the supermarket, then to the server
# using knife
knife_options = "--config #{node['kwik-e-mart']['user']['unix_home']}/.chef/knife.rb --verbose"
upload_dir = node['kwik-e-mart']['upload_dir']

directory upload_dir do
    owner node['kwik-e-mart']['user']['username']
    recursive true
end

#Dir.glob( "#{upload_dir}/*.tar.gz" ).each do |archive|
#    file ::File.expand_path(archive) do

deploy_revision 'happiness' do
    repository 'git@github.com:FredHutch/congenial-happiness.git'
    user 'btb'
    deploy_to upload_dir
    revision '0.2.0'
    migrate false
    symlink_before_migrate.clear
    create_dirs_before_symlink.clear
    purge_before_symlink.clear
    symlinks.clear
end

