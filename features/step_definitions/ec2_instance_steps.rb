Given(/^I request an instance named "(.*?)" on domain "(.*?)" using chef environment "(.*?)" specifying a run list "(.*?)"$/) do |name, domain, chef_environment, run_list|
  visit '/aws/ec2_instances/new'
  fill_in "Name", with: name
  fill_in "Domain", with: domain
  fill_in "Chef environment", with: chef_environment
  fill_in "Run list", with: run_list
  click_on 'Create'
end

Then(/^an instance build should be started$/) do
  #
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
