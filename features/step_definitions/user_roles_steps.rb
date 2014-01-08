Given(/^I am a (\w+_?\w*)/) do |role|
  User.first.update_attribute(:role, role)
  page.visit current_path
end

Given(/^a "(.*?)" (\w+_?\w*)$/) do |name, role|
  FactoryGirl.create(:user, name: name, role: role)
end

Then(/^"(.*?)" should be a (\w+_?\w*)$/) do |name, role|
  expect(User.where(name: name, role: role)).to exist
end

When(/^I set "(.*?)" role$/) do |role|
  select role.underscore.gsub(' ', '_'), from: 'Role'
end
