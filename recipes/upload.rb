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
# source directory- these should be cookbooks delivered from
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

Dir.glob( "#{upload_dir}/*.tar.gz" ).each do |archive|
    workdir= "#{upload_dir}/#{::File.basename(archive, '.tar.gz')}"
    log 'archive extraction' do
        level :warn
        message "Extracting #{archive} into #{workdir}"
    end
    directory workdir do
        owner node['kwik-e-mart']['user']['username']
        recursive true
    end
    bash 'extract cookbook' do
        cwd workdir
        code "tar xvf #{archive} --strip=1"
    end
    # Read metatdata for cookbook name
    md_read = Chef::Cookbook::Metadata.new()
    cookbook_md = md_read.from_file("#{workdir}/metadata.rb")
    cookbook_name = md_read.name
    log 'a man needs a name' do
        level :warn
        message "cookbook name is #{cookbook_name}"
    end
    execute 'upload to supermarket' do
        command "knife supermarket share #{cookbook_name} -o .. #{knife_options}"
        user node['kwik-e-mart']['user']['username']
        environment ({ 'HOME' => node['kwik-e-mart']['user']['unix_home'] })
        cwd workdir
        live_stream true
    end
end

