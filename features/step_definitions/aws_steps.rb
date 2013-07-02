Given(/^I am on the EC2s page$/) do
  visit '/aws/ec2s'
end
Then(/^I should see Groups "(.*?)"$/) do |some_text|
  expect(page.text).to include(some_text)
end

Given(/^I am on the AMIs page$/) do
  visit '/aws/amis'
end
Then(/^I should see Architecture "(.*?)"$/) do |some_text|
  expect(page.text).to include(some_text)
end

Given(/^I am on the Security Groups Page$/) do
  visit '/aws/security_groups'
end

Then(/^I should see Description"(.*?)"$/) do |some_text|
  expect(page.text).to include(some_text)
end

Given(/^I am on the VCP Groups Page$/) do
  visit '/aws/vpcs'
end

Then(/^I should see State "(.*?)"$/) do |some_text|
  expect(page.text).to include(some_text)
end