Given(/^ami\-(\w+) "(.*?)" exists in AWS$/) do |id, name|
  stub_ami_info("ami-#{id}", name)
end

Given(/^(hidden )?"(.*?)" AMI$/) do |hidden, name|
  ami = FactoryGirl.create(:ami, name: name, hidden: hidden.present?)
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
