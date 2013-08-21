require "#{Rails.root}/spec/support/chef_builders"
Around('@chef-zero') do |scenario, block|
  Chef::Config[:chef_server_url] = 'http://127.0.0.1:8889'
  ChefZero::SingleServer.instance
  block.call
  ChefZero::SingleServer.instance.clean
end

World(ChefBuilders)
