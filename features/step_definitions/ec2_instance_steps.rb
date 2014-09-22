Given(/^AWS has information about machines$/) do
  stub_security_groups
  stub_subnets
  ami = FactoryGirl.create(:ami)
  stub_ami_info(ami.ami_id)
end

Given(/^queues and topics are configured$/) do
  stub_sns
  stub_sqs
  config = CONFIG.deep_dup
  config['aws']["ec2_instance_stop_topic_arn"] = "arn:aws:sns:eu-west-1:9:ec2_instance_stop_topic_arn"
  config['aws']["ec2_instance_start_topic_arn"] = "arn:aws:sns:eu-west-1:9:ec2_instance_start_topic_arn"
  config['aws']["ec2_instance_delete_topic_arn"] = "arn:aws:sns:eu-west-1:9:ec2_instance_delete_topic_arn"
  config['aws']["ec2_instance_boot_topic_arn"] = "arn:aws:sns:eu-west-1:9:ec2_instance_boot_topic_arn"
  config['aws']["ec2_instance_resize_topic_arn"] = "arn:aws:sns:eu-west-1:9:ec2_instance_resize_topic_arn"
  config['aws']["jenkins_slave_delete_topic_arn"] = "arn:aws:sns:eu-west-1:9:jenkins_slave_delete_topic_arn"
  stub_const('CONFIG', config)
end

Given(/^I request an instance named "(.*?)"$/) do |name|
  visit '/aws/ec2_instances/new'
  fill_in_default_values(name)
  click_on 'Create'
end

def fill_in_default_values(name)
  fill_in "Name", with: name
  find(:select, 'Environment').all(:option).last.select_option
  fill_in "Run list", with: 'role[ted]'
  find(:select, 'Ami').all(:option).last.select_option
  select 't1.micro', from: 'Flavor'
  select '42', from: 'Subnet'
  check("#{CONFIG['pantry']['security_groups_prefix']}APIServer-001122334455")
end

When(/^I enter all required data for ec2$/) do
  fill_in_default_values('new-instance')
end

When(/^I entered ami\-(\w+) in custom ami field$/) do |id|
  fill_in 'Custom AMI', with: "ami-#{id}"
  fill_in "Name", with: 'new-instance'
end

Then(/^an instance (?:with ami\-(\w+) )?build should start$/) do |ami|
  expect(AWS::SNS.new.client).to have_received(:publish).with(hash_including(topic_arn: "arn:aws:sns:eu-west-1:9:ec2_instance_boot_topic_arn")) do |args|
    message = JSON.parse(JSON.parse(args[:message])['default'])
    expect(message['ami']).to match(ami) if ami
    expect(message["block_device_mappings"]).to be_all{|hash| hash['ebs']['volume_size'].present?}
  end
end

When(/^an instance is created with ip "(.*?)"$/) do |ip|
  instance = Ec2Instance.last
  header 'X-Auth-Token', CONFIG['pantry']['api_key']
  put "/api/ec2_instances/#{instance.id}", { user_id: instance.user_id, event: :ec2_booted, ip_address: ip, instance_id: 'i-12345', format: :json}
  header 'X-Auth-Token', CONFIG['pantry']['api_key']
  put "/api/ec2_instances/#{instance.id}", { user_id: instance.user_id, joined: true, format: :json}
  header 'X-Auth-Token', CONFIG['pantry']['api_key']
  put "/api/ec2_instances/#{instance.id}", { user_id: instance.user_id, event: :create_dns_record, format: :json, dns: true}
  header 'X-Auth-Token', CONFIG['pantry']['api_key']
  put "/api/ec2_instances/#{instance.id}", { user_id: instance.user_id, bootstrapped: true, format: :json}
end

When(/^I select four security groups$/) do
  check("#{CONFIG['pantry']['security_groups_prefix']}APIServer-001122334455")
  check("#{CONFIG['pantry']['security_groups_prefix']}WebServer-001122334455")
  check("#{CONFIG['pantry']['security_groups_prefix']}GraphiteServer-001122334455")
  check("#{CONFIG['pantry']['security_groups_prefix']}JavaServer-001122334455")
end

Then(/^shut down request should be sent$/) do
  expect(AWS::SNS.new.client).to have_received(:publish).with(hash_including(topic_arn: "arn:aws:sns:eu-west-1:9:ec2_instance_stop_topic_arn"))
end

When(/^machine is shut down$/) do
  instance = Ec2Instance.last
  header 'X-Auth-Token', CONFIG['pantry']['api_key']
  put "/api/ec2_instances/#{instance.id}", { user_id: instance.user_id, event: :shutdown, format: :json}
end

Then(/^start request should be sent$/) do
  expect(AWS::SNS.new.client).to have_received(:publish).with(hash_including(topic_arn: 'arn:aws:sns:eu-west-1:9:ec2_instance_start_topic_arn'))
end

When(/^machine is started$/) do
  instance = Ec2Instance.last
  header 'X-Auth-Token', CONFIG['pantry']['api_key']
  put "/api/ec2_instances/#{instance.id}", { user_id: instance.user_id, event: :started, format: :json}
end

When(/^the instance is ready$/) do
  @instance = Ec2Instance.last
  @instance.update_attributes(state: "ready")
  @instance.reload
end

Then(/^I should not be able to add a fifth security group$/) do
  expect{ check("#{CONFIG['pantry']['security_groups_prefix']}PHPServer-001122334455") }.to raise_error # because it is grayed out (fifth check box)
end

Then(/^instance destroying process should start$/) do
  expect(AWS::SNS.new.client).to have_received(:publish).with(hash_including(topic_arn: 'arn:aws:sns:eu-west-1:9:ec2_instance_delete_topic_arn'))
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
  wait_until(5) do
    page.has_content? 'Terminated'
  end
  expect(page.text).to include('Terminated')
end

Then(/^I should not see machine info$/) do
  expect(page).not_to have_text(Ec2Instance.last.name)
end

When(/^instance load is "(.*?)"$/) do |load|
  metrics = AWS::CloudWatch.new.client.stub_for(:list_metrics)
  metrics[:metrics] = [{metric_name: 'CPUUtilization', namespace: 'Test'}]
  statistics = AWS::CloudWatch.new.client.stub_for :get_metric_statistics
  statistics[:datapoints] =  [{timestamp: Time.current, unit: 'Percent', average: load.to_d}]
end

Given(/^an EC2 instance$/) do
  @ec2_instance = FactoryGirl.create(:ec2_instance)
end

Given(/^I have (?:an|(\w+)) EC2 instance in the team$/) do |size|
  user = User.first
  if user.teams.empty?
    @team = FactoryGirl.create(:team)
    @team.users << user
  else
    @team = user.teams.first
  end

  @ec2_instance = FactoryGirl.create(:ec2_instance, :running, user: user, team: @team, flavor: size|| 'm1.small')
end

Then(/^I should see machine info$/) do
  expect(page).to have_text(Ec2Instance.last.name)
end

When(/^I click on instance size$/) do
  find(:xpath,"//div[contains(text(),'#{@ec2_instance.flavor}')]").click
end

When(/^I set (.*) as new size$/) do |size|
  select size, from: 'Flavor'
  click_on "Resize"
end

Then(/^request for resize should be sent$/) do
  expect(AWS::SNS.new.client).to have_received(:publish).with(hash_including(topic_arn: 'arn:aws:sns:eu-west-1:9:ec2_instance_resize_topic_arn'))
end

When(/^machine is resized with "(.*?)"$/) do |size|
  header 'X-Auth-Token', CONFIG['pantry']['api_key']
  put "/api/ec2_instances/#{@ec2_instance.id}", { user_id: @ec2_instance.user_id, event: :resized, flavor: size, format: :json}
end

Then(/^I should not be able to create EC2 Instance$/) do
  visit "/aws/ec2_instances/new"
  expect(page.current_path).to eq "/"
  visit "/jenkins_servers/new"
  expect(page.current_path).to eq "/"
end
