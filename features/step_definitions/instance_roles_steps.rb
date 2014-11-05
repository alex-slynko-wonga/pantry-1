Given(/^"(.*?)" instance role is disabled$/) do |name|
  instance_role = FactoryGirl.create(:instance_role, name: name, enabled: false)
  stub_ami_info(instance_role.ami.ami_id)
end

Given(/^"(.*?)" instance role with "(.*?)" Ami platform$/) do |name, ami_platform|
  ami = FactoryGirl.create(:ami, platform: ami_platform, name: ami_platform)
  instance_role = FactoryGirl.create(:instance_role, name: name, enabled: false, ami: ami)
  stub_ami_info(instance_role.ami.ami_id)
end

Given(/^"(.*?)" instance role$/) do |name|
  instance_role = FactoryGirl.create(:instance_role, name: name)
  stub_ami_info(instance_role.ami.ami_id)
end

Given(/^instance role for Jenkins Server$/) do
  instance_role = FactoryGirl.create(:instance_role, :for_jenkins_server)
  stub_ami_info(instance_role.ami.ami_id)
end

Given(/^instance role for Jenkins Slave$/) do
  instance_role = FactoryGirl.create(:instance_role, :for_jenkins_slave)
  stub_ami_info(instance_role.ami.ami_id)
end
