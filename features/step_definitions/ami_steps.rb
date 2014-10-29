Given(/^ami\-(\w+) "(.*?)" exists in AWS( with platform "(.*?)")?$/) do |id, name, platform_exist, platform|
  if platform_exist
    stub_ami_info("ami-#{id}", name, platform)
  else
    stub_ami_info("ami-#{id}", name)
  end
end

Given(/^(hidden )?"(.*?)" AMI( with platform "(.*?)")?$/) do |hidden, name, platform_exist, platform|
  if platform_exist
    ami = FactoryGirl.create(:ami, name: name, hidden: hidden.present?, platform: platform)
  else
    ami = FactoryGirl.create(:ami, name: name, hidden: hidden.present?)
  end
  stub_ami_info(ami.ami_id)
end

Then(/^"(.*?)" AMI should be available for instance creation$/) do |name|
  visit '/aws/ec2_instances/new'
  expect(find_field('Ami')).to have_xpath("//option[text()='#{name}']")
end

Then(/^"(.*?)" AMI should not be available for instance creation$/) do |name|
  visit '/aws/ec2_instances/new'
  expect(find_field('Ami')).not_to have_xpath("//option[text()='#{name}']")
end
