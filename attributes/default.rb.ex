
node.default['kwik-e-mart']['knife-config'] = {
    'supermarket_site' => 'https://knife-server.your.org',
    'chef_server_url' => 'https://chef-server.your.org/organizations/your-org',
    'chef_server_username' => 'chef-login-name'
}

node.default['kwik-e-mart']['user'] = {
    'username' => 'service-user',
    'unix_home' => '/home/service_user'
}

# Path to cookbook sources for upload
node.default['kwik-e-mart']['upload_dir'] = "#{node['kwik-e-mart']['user']['unix_home']}/cookbooks"
