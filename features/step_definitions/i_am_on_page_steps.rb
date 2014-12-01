Given(/^I am on the AMIs page$/) do
  visit admin_amis_path
end

Given(/^I am on the InstanceRoles page$/) do
  visit admin_instance_roles_path
end

Given(/^I am on the ApiKeys page$/) do
  visit admin_api_keys_path
end

Given(/^I am on root page$/) do
  visit '/'
end

Then(/^I should be on team page$/) do
  expect(current_url).to match(/teams/)
end

Given(/^I am on the teams page$/) do
  click_on 'Teams'
end

When(/^I am still on \w+ page$/) do
  visit page.current_path
end

Given(/^I (?:visit|am on the) ec2 instance new page$/) do
  visit '/aws/ec2_instances/new'
  expect(page).to have_content 'Create EC2 Instance'
end

When(/^I am on instance page$/) do
  if @ec2_instance
    visit "/aws/ec2_instances/#{@ec2_instance.id}"
  else
    visit "/aws/ec2_instances/#{Ec2Instance.last.id}"
  end
end

When(/^I proceed to "(.*?)" page$/) do |page_name|
  links = all('.navbar .navbar-inner ul.nav li a')
  link = links.detect { |l| l.text == page_name }
  link.click
end

When(/^I proceed to "(.*?)" user page$/) do |name|
  click_on 'Users'
  click_on name
end

Given(/^I am on the "(.*?)" team page$/) do |team_name|
  visit root_path
  click_on 'Teams'
  click_on team_name
end

When(/^I check my profile page$/) do
  visit user_path User.first
end

When(/^I am on the team page$/) do
  visit root_path
  click_on 'Teams'
  click_on @team.name
end

When(/^I am on the user page$/) do
  visit root_path
  click_on 'Users'
  click_on User.first.name
end

When(/^I go into Jenkins slave page$/) do
  visit "/jenkins_servers/#{@jenkins_slave.jenkins_server_id}/jenkins_slaves/#{@jenkins_slave.id}"
end

When(/^I am on environment page$/) do
  @environment = Environment.last
  visit "/environments/#{@environment.id}"
end
