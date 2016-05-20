#
# Cookbook Name:: kwik-e-mart
# Recipe:: upload
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

execute "list_cookbooks" do
    command "knife supermarket show congenial-happiness 0.1.33 --config /var/spool/btb/.chef/knife.rb --verbose"
    live_stream true
    user 'btb'
end
execute "whoami" do
    command "whoami"
    live_stream true
    user 'btb'
end
