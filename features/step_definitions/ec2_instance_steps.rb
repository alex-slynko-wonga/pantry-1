Given(/^AWS has information about machines$/) do
  client = AWS::EC2.new.client
  security_groups = client.stub_for(:describe_security_groups)
  security_groups[:security_group_info] = [
    { group_name: 'name1', group_id: '1' },
    { group_name: 'name2', group_id: '2' },
    { group_name: 'name3', group_id: '3' },
    { group_name: 'name4', group_id: '4' },
    { group_name: 'name5', group_id: '5' }
  ]
  subnets = client.stub_for(:describe_subnets)
  subnets[:subnet_set] = [ { subnet_id: '42' } ]
  amis = client.stub_for(:describe_images)
  amis[:images_set] = [ { name: 'image_name', image_id: 'i-121111' } ]
  amis[:image_index] = { 'i-121111' => {:platform => 'windows'}}
end

Given(/^queues and topics are configured$/) do
  sns_client = AWS::SNS.new.client
  sns_client.stub(:publish).and_return(AWS::Core::Response.new)

  sqs_client = AWS::SQS.new.client
  resp = sqs_client.stub_for(:get_queue_url)
  resp[:queue_url] = "https://some_url.example.com"
  sqs_client.stub(:send_message).and_return(AWS::Core::Response.new)
end

Given(/^I request an instance named "(.*?)"$/) do |name|
  visit '/aws/ec2_instances/new'
  fill_in_default_values(name)
  click_on 'Create'
end

def fill_in_default_values(name)
  fill_in "Name", with: name
  fill_in "Chef environment", with: 'chef_environment'
  fill_in "Run list", with: 'role[ted]'
  find(:select, 'Ami').all(:option).last.select_option
  select 't1.micro', from: 'Flavor'
  select '42', from: 'Subnet'
  check('name1')
end

Given(/^ami\-(\w+) "(.*?)" exists in AWS$/) do |id, name|
  client = AWS::EC2.new.client
  amis = client.stub_for(:describe_images)
  amis[:images_set] = [{ name: name, image_id: "ami-#{id}" }]
  amis[:image_index] = { "ami-#{id}" => {:platform => 'windows'}}
end

When(/^I enter all required data for ec2$/) do
  fill_in_default_values('new_instance')
end

When(/^I entered ami\-(\w+) in custom ami field$/) do |id|
  fill_in 'Custom AMI', with: "ami-#{id}"
  fill_in "Name", with: 'new_instance'
end

Then(/^an instance (?:with ami\-(\w+) )?build should start$/) do |ami|
  expect(AWS::SNS.new.client).to have_received(:publish) do |*args|
    expect(args[0][:message]).to match(ami) if ami
  end
end

When(/^an instance is created with ip "(.*?)"$/) do |ip|
  instance = Ec2Instance.last
  header 'X-Auth-Token', CONFIG['pantry']['api_key']
  put "/api/ec2_instances/#{instance.id}", { user_id: instance.user_id, booted: true, ip_address: ip, format: :json}
  header 'X-Auth-Token', CONFIG['pantry']['api_key']
  put "/api/ec2_instances/#{instance.id}", { user_id: instance.user_id, joined: true, format: :json}
  header 'X-Auth-Token', CONFIG['pantry']['api_key']
  put "/api/ec2_instances/#{instance.id}", { user_id: instance.user_id, event: :create_dns_record, format: :json}
  header 'X-Auth-Token', CONFIG['pantry']['api_key']
  put "/api/ec2_instances/#{instance.id}", { user_id: instance.user_id, bootstrapped: true, format: :json}
end

When(/^I select four security groups$/) do
  check('name1')
  check('name2')
  check('name3')
  check('name4')
end

When(/^the instance is shutdown$/) do
  @instance = Ec2Instance.last
  @instance.update_attributes(state: "shutdown", booted: false)
  @instance.reload
end

When(/^the instance is ready$/) do
  @instance = Ec2Instance.last
  @instance.update_attributes(state: "ready", booted: true)
  @instance.reload
end

Then(/^I should not be able to add a fifth security group$/) do
  expect{ check('name5') }.to raise_error # because it is grayed out
end

Then(/^instance destroying process should start$/) do
  expect(AWS::SNS.new.client).to have_received(:publish)
end

When(/^an instance is destroyed$/) do
  instance = Ec2Instance.last
  user_id = instance.user_id
  header 'X-Auth-Token', CONFIG['pantry']['api_key']
  put "/api/ec2_instances/#{instance.id}", {user_id: user_id, terminated: true, format: :json}
  header 'X-Auth-Token', CONFIG['pantry']['api_key']
  delete "/api/chef_nodes/#{instance.id}", { user_id: user_id, format: :json}
  header 'X-Auth-Token', CONFIG['pantry']['api_key']
  put "/api/ec2_instances/#{instance.id}", {user_id: user_id, joined: false, format: :json}
  expect(instance.reload.state).to_not eq('terminated')
  header 'X-Auth-Token', CONFIG['pantry']['api_key']
  put "/api/ec2_instances/#{instance.id}", {user_id: user_id, event: :terminated, dns: false, format: :json}
end

Given(/^the (?:instance|jenkins slave) is protected$/) do
  instance = Ec2Instance.last
  instance.protected = true
  instance.save
end

Then(/^I should see that instance is destroyed$/) do
  expect(page).to have_no_button('Destroy')
  expect(page.text).to include('Terminated')
end

When(/^instance load is "(.*?)"$/) do |load|
  metrics = AWS::CloudWatch.new.client.stub_for(:list_metrics)
  metrics[:metrics] = [{metric_name: 'CPUUtilization', namespace: 'Test'}]
  statistics = AWS::CloudWatch.new.client.stub_for :get_metric_statistics
  statistics[:datapoints] =  [{timestamp: Time.current, unit: 'Percent', average: load.to_d}]
end

When(/^an EC2 instance$/) do
  @ec2_instance = FactoryGirl.create(:ec2_instance)
end

Given(/^I have at least one EC2 in the team$/) do
  user = User.first
  if user.teams.empty?
    @team = FactoryGirl.create(:team)
    @team.users << user
  else
    @team = user.teams.first
  end

  @ec2_instance = FactoryGirl.create(:ec2_instance, :running, user: user, team: @team)
end

Then(/^I should see machine info$/) do
  expect(page).to have_text(Ec2Instance.last.name)
end
