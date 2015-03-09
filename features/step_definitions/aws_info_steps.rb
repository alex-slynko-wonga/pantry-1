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

Given(/^I have "(.*?)" IAM$/) do |iam|
  stub_iam(iam) if iam
  stub_iam unless iam
end

When(/^flavors are configured$/) do
  config = CONFIG.deep_dup
  config['aws']['ebs'] = { 'c3.2xlarge' => 10, 'm3.xlarge' => 500, 't1.micro' => 80 }
  stub_const('CONFIG', config)
end
