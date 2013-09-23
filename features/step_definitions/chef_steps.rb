Then(/^new chef environment "(.*?)" should be created$/) do |chef_env_name|
  expect(Chef::Environment.list).to have_key(chef_env_name)
end

Then(/^a new chef environment should be requested$/) do
  expect(AWS::SQS.new.client).to have_received(:send_message)
end

Given(/^the node "(.*?)" with environment "(.*?)"$/) do |node_name, environment|
  build_chef_node(node_name, environment)
end


