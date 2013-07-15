Given(/^I request an instance named "(.*?)"$/) do |name|
  visit '/aws/ec2_instances/new'
  fill_in "Name", with: name
  click_on 'Create'
end

Then(/^an instance build should be started$/) do
  #
end

When(/^an instance is created$/) do
  p "FIXME when job will be ready"
  instance = Ec2Instance.last
  instance.bootstrapped = true
  instance.joined = true
  instance.save
end

When(/^I am still on instance page$/) do
  visit page.current_path
end
