Given(/^I am on root page$/) do
  visit '/'
end

Then(/^I should be on team page$/) do
  current_url.should =~ /teams/
end

Given(/^I am on the teams page$/) do
  click_on "Teams"
end

When(/^I am still on \w+ page$/) do
  visit page.current_path
end

Given(/^I (?:visit|am on the) ec2 instance new page$/) do
  visit '/aws/ec2_instances/new'
  page.should have_content 'Create EC2 Instance'
end

When(/^I am on instance page$/) do
  visit "/aws/ec2_instances/#{@ec2_instance.id}"
end

When(/^I proceed to "(.*?)" page$/) do |page_name|
  links = all('.navbar .navbar-inner ul.nav li a')
  link = links.detect { |l| l.text == page_name }
  link.click
end

When(/^I proceed to "(.*?)" user page$/) do |name|
  click_on "Users"
  click_on name
end

Given(/^I am on the "(.*?)" team page$/) do |arg1|
  visit team_path @team
end

When(/^I check my profile page$/) do
  visit user_path User.first
end

When(/^I go into Jenkins slave page$/) do
  visit "/jenkins_servers/#{@jenkins_slave.jenkins_server_id}/jenkins_slaves/#{@jenkins_slave.id}"
end
