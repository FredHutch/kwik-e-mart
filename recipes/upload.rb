#
# Cookbook Name:: kwik-e-mart
# Recipe:: upload
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

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

workdirs = Array.new

ruby_block "atend" do
    action :nothing
    block do
        workdirs.each do |dir|
            Chef::Log.warn( "dir is #{dir}" )
            md_read = Chef::Cookbook::Metadata.new()
            cookbook_md = md_read.from_file("#{dir}/metadata.rb")
            cookbook_name = md_read.name
            Chef::Log.warn( "cookbook name is #{cookbook_name}" )
            cmd = ::Mixlib::ShellOut.new(
              "knife supermarket share #{cookbook_name} -o .. #{knife_options}",
              :user => node['kwik-e-mart']['user']['username'],
              :cwd => dir
            )
            cmd.run_command
            cmd.error!
            Chef::Log.warn( "Supermarket upload OK: #{cmd.stdout}" )
            cmd = ::Mixlib::ShellOut.new(
              "knife cookbook upload #{cookbook_name} -o .. #{knife_options}",
              :user => node['kwik-e-mart']['user']['username'],
              :cwd => dir
            )
            cmd.run_command
            cmd.error!
            Chef::Log.warn( "Upload to server OK: #{cmd.stdout}" )
            ::FileUtils.rm_r dir
        end
    end
end


Dir.glob( "#{upload_dir}/*.tar.gz" ).each do |archive|
    dirname = ::File.basename(archive, '.tar.gz')
    workdir = "#{upload_dir}/#{dirname}"
    bash "#{workdir} cleanup" do
        cwd upload_dir
        user node['kwik-e-mart']['user']['username']
        code "rm -f #{workdir}"
    end
    log "#{dirname} archive extraction" do
        level :warn
        message "Extracting #{archive} into #{workdir}"
    end
    directory "#{dirname}_create" do
        path workdir
        owner node['kwik-e-mart']['user']['username']
        recursive true
    end
    bash "#{dirname} extract cookbook" do
        cwd workdir
        user node['kwik-e-mart']['user']['username']
        code "tar xvf #{archive} --strip=1 && rm -f #{archive}"
        creates "#{workdir}/metadata.rb"
    end
    ruby_block "add_to_workdirs" do
        block do
            workdirs.push( workdir )
        end
        notifies :create, resources("ruby_block[atend]"), :delayed
    end

end
