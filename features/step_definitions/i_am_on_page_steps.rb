Given(/^I am on root page$/) do
  visit '/'
end

Then(/^I should be on team page$/) do
  current_url.should =~ /teams/
end

Given(/^I am on the teams page$/) do
  visit "/teams"
end

When(/^I am still on \w+ page$/) do
  visit page.current_path
end

Given(/^I visit ec2 instance new page$/) do
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

