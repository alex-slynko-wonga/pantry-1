Given(/^AWS has information about machines$/) do
  client = AWS::EC2.new.client
  security_groups = client.stub_for(:describe_security_groups)
  security_groups[:security_group_info] = [ { group_name: 'name', group_id: '1' } ]
  subnets = client.stub_for(:describe_subnets)
  subnets[:subnet_set] = [ { subnet_id: '42' } ]
  amis = client.stub_for(:describe_images)
  amis[:images_set] = [ { name: 'image_name', image_id: 'i-121111' } ]
  sqs_client = AWS::SQS.new.client
  resp = sqs_client.stub_for(:get_queue_url)
  resp[:queue_url] = "http://some_url.example.com"
  sqs_client.stub(:send_message).and_return(AWS::Core::Response.new)
end

Given(/^I request an instance named "(.*?)" on domain "(.*?)"$/) do |name, domain|
  visit '/aws/ec2_instances/new'
  fill_in "Name", with: name
  fill_in "Domain", with: domain
  fill_in "Chef environment", with: 'chef_environment'
  fill_in "Run list", with: 'role[ted]'
  select 'image_name', from: 'Ami'
  select 't1.micro', from: 'Flavor'
  select '42', from: 'Subnet'
  select 'name', from: 'Security group ids'
  click_on 'Create'
end

Then(/^an instance build should start$/) do
  expect(AWS::SQS.new.client).to have_received(:send_message)
end

When(/^an instance is created$/) do
  instance = Ec2Instance.last
  instance.bootstrapped = true
  instance.joined = true
  instance.save
end

When(/^I am still on instance page$/) do
  visit page.current_path
end
