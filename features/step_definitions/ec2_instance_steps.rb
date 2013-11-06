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
  fill_in "Name", with: name
  fill_in "Chef environment", with: 'chef_environment'
  fill_in "Run list", with: 'role[ted]'
  select 'image_name', from: 'Ami'
  select 't1.micro', from: 'Flavor'
  select '42', from: 'Subnet'
  check('name1')
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

When(/^an instance is updated with ip "(.*?)"$/) do |arg1|
  instance = Ec2Instance.last
  instance.complete!({"ip_address" => "123.456.7.8"})
  instance.save
end

When(/^I select four security groups$/) do
  check('name1')
  check('name2')
  check('name3')
  check('name4')
end

Then(/^I should not be able to add a fifth security group$/) do
  expect{ check('name5') }.to raise_error # because it is grayed out
end

Then(/^instance destroying process should start$/) do
  expect(AWS::SNS.new.client).to have_received(:publish)
end

When(/^an instance is destroyed$/) do
  Ec2Instance.last.update_attribute(:terminated, true)
end

Then(/^I should see that instance is destroyed$/) do
  expect(page).to have_no_button('Destroy')
  expect(page.text).to include('Terminated')
end
