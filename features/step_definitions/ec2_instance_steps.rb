Given(/^AWS has information about machines$/) do
  stub_security_groups
  stub_subnets
  windows_ami = FactoryGirl.create(:ami, platform: 'windows')
  stub_ami_info(windows_ami.ami_id)
  linux_ami = FactoryGirl.create(:ami, platform: 'linux', name: 'linux')
  stub_ami_info(linux_ami.ami_id)
end

Given(/^AWS pricing is broken$/) do
  allow_any_instance_of(Wonga::Pantry::PricingList).to receive(:get_instance_type).and_raise('some error')
end

Given(/^queues and topics are configured$/) do
  stub_sns
  stub_sqs
  config = CONFIG.deep_dup
  config['aws']['ec2_instance_stop_topic_arn'] = 'arn:aws:sns:eu-west-1:9:ec2_instance_stop_topic_arn'
  config['aws']['ec2_instance_start_topic_arn'] = 'arn:aws:sns:eu-west-1:9:ec2_instance_start_topic_arn'
  config['aws']['ec2_instance_delete_topic_arn'] = 'arn:aws:sns:eu-west-1:9:ec2_instance_delete_topic_arn'
  config['aws']['ec2_instance_boot_topic_arn'] = 'arn:aws:sns:eu-west-1:9:ec2_instance_boot_topic_arn'
  config['aws']['ec2_instance_resize_topic_arn'] = 'arn:aws:sns:eu-west-1:9:ec2_instance_resize_topic_arn'
  config['aws']['jenkins_slave_delete_topic_arn'] = 'arn:aws:sns:eu-west-1:9:jenkins_slave_delete_topic_arn'
  stub_const('CONFIG', config)
end

When(/^flavors are configured$/) do
  config = CONFIG.deep_dup
  config['aws']['ebs'] = { 'c3.2xlarge' => 10, 'm3.xlarge' => 500, 't1.micro' => 80 }
  stub_const('CONFIG', config)
end

Given(/^I request an instance named "(.*?)"$/) do |name|
  visit '/aws/ec2_instances/new'
  fill_in_default_values(name)
  click_on 'Create'
end

When(/^I request an instance with "(.*?)" AMI$/) do |ami_name|
  visit '/aws/ec2_instances/new'
  fill_in_default_values('new-instance')
  find(:select, text: ami_name).select_option
  click_on 'Create'
end

When(/^I request an EC2 instance$/) do
  visit '/aws/ec2_instances/new'
end

When(/^I request an EC2 instance for team "(.*?)"$/) do |team_name|
  @team = Team.where(name: team_name).first
  visit '/aws/ec2_instances/new?team_id=' + @team.id.to_s
end

When(/^I have "(.*?)" instance$/) do |instance_size|
  @team = Team.last
  @ami = Ami.last
  @ec2_instance = FactoryGirl.create(:ec2_instance, team: @team, flavor: instance_size, ami: @ami.ami_id)
end

Then(/^I should see new ec2 instance form with prefilled values$/) do
  expect(page).to have_select('Environment', selected: @ec2_instance.environment.name)
  expect(page).to have_select('Ami', selected: @ami.name)
  expect(page).to have_select('Flavor', selected: @ec2_instance.flavor)
end

When(/^instance with "(.*?)" role belong to "(.*?)"$/) do |role_name, team_name|
  @team = Team.where(name: team_name).first
  @instance_role = FactoryGirl.create(:instance_role, name: role_name)
  FactoryGirl.create(:ec2_instance, instance_role_id: @instance_role.id, team: @team)
end

def fill_in_default_values(name)
  fill_in 'Name', with: name
  find(:select, 'Environment').all(:option).last.select_option
  fill_in 'Run list', with: 'role[ted]'
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
  fill_in 'Name', with: 'new-instance'
end

Then(/^the instance start using "(.*?)" bootstrap username$/) do |bootstrap_username|
  expect(AWS::SNS.new.client).to have_received(:publish).with(hash_including(topic_arn: 'arn:aws:sns:eu-west-1:9:ec2_instance_boot_topic_arn')) do |args|
    message = JSON.parse(JSON.parse(args[:message])['default'])
    expect(message['bootstrap_username']).to match(bootstrap_username)
  end
end

Then(/^an instance (?:with ami\-(\w+) )?build should start$/) do |ami|
  expect(AWS::SNS.new.client).to have_received(:publish).with(hash_including(topic_arn: 'arn:aws:sns:eu-west-1:9:ec2_instance_boot_topic_arn')) do |args|
    message = JSON.parse(JSON.parse(args[:message])['default'])
    expect(message['ami']).to match(ami) if ami
    expect(message['block_device_mappings']).to be_all { |hash| hash['ebs']['volume_size'].present? }
    expect(message['block_device_mappings'].size).to be > 0
  end
end

When(/^an instance is created with ip "(.*?)"$/) do |ip|
  instance = Ec2Instance.last
  header 'X-Auth-Token', CONFIG['pantry']['api_key']
  put "/api/ec2_instances/#{instance.id}", user_id: instance.user_id, event: :ec2_booted, ip_address: ip, instance_id: 'i-12345', format: :json
  header 'X-Auth-Token', CONFIG['pantry']['api_key']
  put "/api/ec2_instances/#{instance.id}", user_id: instance.user_id, joined: true, format: :json
  header 'X-Auth-Token', CONFIG['pantry']['api_key']
  put "/api/ec2_instances/#{instance.id}", user_id: instance.user_id, event: :create_dns_record, format: :json, dns: true
  header 'X-Auth-Token', CONFIG['pantry']['api_key']
  put "/api/ec2_instances/#{instance.id}", user_id: instance.user_id, bootstrapped: true, format: :json
end

When(/^I select four security groups$/) do
  check("#{CONFIG['pantry']['security_groups_prefix']}APIServer-001122334455")
  check("#{CONFIG['pantry']['security_groups_prefix']}WebServer-001122334455")
  check("#{CONFIG['pantry']['security_groups_prefix']}GraphiteServer-001122334455")
  check("#{CONFIG['pantry']['security_groups_prefix']}JavaServer-001122334455")
end

Then(/^shut down request should be sent(?: (.*) times)?$/) do |requests_count|
  hash_content = { topic_arn: 'arn:aws:sns:eu-west-1:9:ec2_instance_stop_topic_arn' }
  if requests_count
    expect(AWS::SNS.new.client).to have_received(:publish).exactly(requests_count.to_i).times.with(hash_including(hash_content))
  else
    expect(AWS::SNS.new.client).to have_received(:publish).with(hash_including(hash_content))
  end
end

When(/^machine is shut down$/) do
  instance = Ec2Instance.last
  header 'X-Auth-Token', CONFIG['pantry']['api_key']
  put "/api/ec2_instances/#{instance.id}", user_id: instance.user_id, event: :shutdown, format: :json
end

When(/^machines with environment "(.*?)" is shut down$/) do |environment_name|
  environment_id = Environment.where(name: environment_name).first.id
  instances = Ec2Instance.where(environment_id: environment_id)
  instances.each do |instance|
    header 'X-Auth-Token', CONFIG['pantry']['api_key']
    put "/api/ec2_instances/#{instance.id}", user_id: instance.user_id, event: :shutdown, format: :json
  end
end

When(/^I receive "(.*?)" event$/) do |name|
  instance = Ec2Instance.last
  header 'X-Auth-Token', CONFIG['pantry']['api_key']
  @response = put "/api/ec2_instances/#{instance.id}", user_id: instance.user_id, event: name, format: :json
end

Then(/^server should respond with success$/) do
  expect(@response.status.to_s).to eq('204') # 204 No Content - http status code
end

Then(/^start request should be sent(?: (.*) times)?$/) do |requests_count|
  hash_content = { topic_arn: 'arn:aws:sns:eu-west-1:9:ec2_instance_start_topic_arn' }
  if requests_count
    expect(AWS::SNS.new.client).to have_received(:publish).exactly(requests_count.to_i).times.with(hash_including(hash_content))
  else
    expect(AWS::SNS.new.client).to have_received(:publish).with(hash_including(hash_content))
  end
end

When(/^machine is started$/) do
  instance = Ec2Instance.last
  header 'X-Auth-Token', CONFIG['pantry']['api_key']
  put "/api/ec2_instances/#{instance.id}", user_id: instance.user_id, event: :started, format: :json
end

When(/^machines with environment "(.*?)" is start$/) do |environment_name|
  environment_id = Environment.where(name: environment_name).first.id
  instances = Ec2Instance.where(environment_id: environment_id)
  instances.each do |instance|
    header 'X-Auth-Token', CONFIG['pantry']['api_key']
    put "/api/ec2_instances/#{instance.id}", user_id: instance.user_id, event: :started, format: :json
  end
end

When(/^the instance is ready$/) do
  @instance = Ec2Instance.last
  @instance.update_attributes(state: 'ready')
  @instance.reload
end

When(/^the instance is booting$/) do
  @instance = Ec2Instance.last
  @instance.update_attributes(state: 'booting')
  @instance.reload
end

When(/^the instance is terminated/) do
  @instance = Ec2Instance.last
  @instance.update_attributes(state: 'terminated')
  @instance.reload
end

Then(/^I should not be able to add a fifth security group$/) do
  expect { check("#{CONFIG['pantry']['security_groups_prefix']}PHPServer-001122334455") }.to raise_error # because it is grayed out (fifth check box)
end

Then(/^instance destroying process should start$/) do
  expect(AWS::SNS.new.client).to have_received(:publish).with(hash_including(topic_arn: 'arn:aws:sns:eu-west-1:9:ec2_instance_delete_topic_arn'))
end

Then(/^instance cleaning process should start$/) do
  expect(AWS::SNS.new.client).to have_received(:publish).with(hash_including(topic_arn: 'arn:aws:sns:eu-west-1:9:ec2_instance_delete_topic_arn'))
end

When(/^an instance is destroyed$/) do
  instance = Ec2Instance.last
  user_id = instance.user_id
  header 'X-Auth-Token', CONFIG['pantry']['api_key']
  put "/api/ec2_instances/#{instance.id}", user_id: user_id, terminated: true, format: :json
  header 'X-Auth-Token', CONFIG['pantry']['api_key']
  delete "/api/chef_nodes/#{instance.id}", user_id: user_id, format: :json
  header 'X-Auth-Token', CONFIG['pantry']['api_key']
  put "/api/ec2_instances/#{instance.id}", user_id: user_id, joined: false, format: :json
  expect(instance.reload.state).to_not eq('terminated')
  header 'X-Auth-Token', CONFIG['pantry']['api_key']
  put "/api/ec2_instances/#{instance.id}", user_id: user_id, event: :terminated, dns: false, format: :json
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
  metrics[:metrics] = [{ metric_name: 'CPUUtilization', namespace: 'Test' }]
  statistics = AWS::CloudWatch.new.client.stub_for :get_metric_statistics
  statistics[:datapoints] =  [{ timestamp: Time.current, unit: 'Percent', average: load.to_d }]
end

Given(/^an EC2 instance$/) do
  @ec2_instance = FactoryGirl.create(:ec2_instance)
end

Given(/^I have (?:an|(\w+)) EC2 instance in the team( with CI environment)?$/) do |size, ci_env_type|
  user = User.first
  if user.teams.empty?
    @team = FactoryGirl.create(:team)
    @team.users << user
  else
    @team = user.teams.first
  end

  if !ci_env_type
    @ec2_instance = FactoryGirl.create(:ec2_instance, :running, user: user, team: @team, flavor: size || 'm1.small')
  else
    @ec2_instance = FactoryGirl.create(:ci_ec2_instance, :running, user: user, team: @team, flavor: size || 'm1.small')
  end

  @environment = @ec2_instance.environment
end

Given(/^I have an EC2 instance in the team with environment "(.*?)"$/) do |environment|
  user = User.first
  @team = user.teams.first
  environment = Environment.where(name: environment).first
  @ec2_instance = FactoryGirl.create(:ec2_instance, :running, user: user, team: @team, environment: environment)
end

Then(/^I should see machine info$/) do
  expect(page).to have_text(Ec2Instance.last.name)
end

When(/^I click on instance size$/) do
  find(:xpath, "//div[contains(text(),'#{@ec2_instance.flavor}')]").click
end

Then(/^"(.*?)" instance details should be present$/) do |instance_size|
  selected_instance = page.find('option', text: instance_size)

  expect(page).to have_content("Price windows: #{selected_instance['data-windows-price']}")
  expect(page).to have_content("Price linux: #{selected_instance['data-linux-price']}")
  expect(page).to have_content("Virtual cores: #{selected_instance['data-cores']}")
  expect(page).to have_content("RAM: #{selected_instance['data-ram']}")
end

When(/^I set (.*) as new size$/) do |size|
  select size, from: 'Flavor'
  click_on 'Resize'
end

Then(/^request for resize should be sent$/) do
  expect(AWS::SNS.new.client).to have_received(:publish).with(hash_including(topic_arn: 'arn:aws:sns:eu-west-1:9:ec2_instance_resize_topic_arn'))
end

When(/^machine is resized with "(.*?)"$/) do |size|
  header 'X-Auth-Token', CONFIG['pantry']['api_key']
  put "/api/ec2_instances/#{@ec2_instance.id}", user_id: @ec2_instance.user_id, event: :resized, flavor: size, format: :json
end

Then(/^I should not be able to create EC2 Instance$/) do
  visit '/aws/ec2_instances/new'
  expect(page.current_path).to eq '/'
  visit '/jenkins_servers/new'
  expect(page.current_path).to eq '/'
end

When(/^I cleanup an instance$/) do
  click_on 'Run machine cleanup'
end
